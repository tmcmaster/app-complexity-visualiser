package Complexity::Analyse;


###################################################################################################################
#
#  Import Section
#


use strict;

use threads;
use Thread;
use Thread::Queue;
use Exporter qw(import);

use lib './lib';
use Complexity::Logger;


###################################################################################################################
#
#  Export Section
#

our @EXPORT = qw(analiseProject createFileWriteQueues closeFileWriteQueues validateTypeMap);

###################################################################################################################
#
#  Static Section
#


my $LOGGER = new Logger('complexity-analise','ERROR',0);


###################################################################################################################
#
#  Function Section
#

#
#  Analise a project from a given perspective.
#
sub analiseProject
{
	my ($typeMap, $type, $writeQueues, @params) = @_;

	my $typeDef = $typeMap->{$type};
	my $command = sprintf($typeDef->{'command'}, @params);
	my $threads = $typeDef->{'threads'};

	$LOGGER->debug("RowVisitor(%s): About to process output: Command(%s) Threads(%d)", $type, $command, $threads);

	return unless ($type ==  'project');
	csvGenericWalkerMultiThreaded($type, $command, $threads, sub {
		
		my $row = join(',', (@_));
		$LOGGER->debug("RowVisitor(%s): Adding row to write queue: %s", $type, $row);
		$writeQueues->{$type}->enqueue($row);

		for my $child (@{$typeDef->{'children'}})
		{
			if (defined $child->{'type'})
			{
				# get child type
				my $childType = $child->{'type'};
				# get the parameters the child type command needs
				my @childParams = @_[@{$child->{'params'}}];

				my @parentParams = (defined $child->{'parent-params'} ? @params : ());

				# analise the child type
				$LOGGER->debug("RowVisitor(%s): About to analise ChildType(%s)", $type, $childType);		
				analiseProject($typeMap, $childType, $writeQueues, @parentParams, @childParams);
				$LOGGER->debug("RowVisitor(%s): Finished analising ChildType(%s)", $type, $childType);		
			}
		}

		$LOGGER->debug("RowVisitor(%s): Finished analising children.", $type);		
	});
}

#
#  DEPRECATED.
# 
sub analiseProjectVersionOne
{
	my ($writeQueues,$typeMap) = @_;

	csvGenericWalkerMultiThreaded('project', sprintf($typeMap->{'project'}->{'command'}), 2, sub {
		my ($projectName,$projectOwner,$projectPath) = @_;
		
		$LOGGER->debug("RowVisitor(%s): ($projectName | $projectOwner | $projectPath)", 'project');

		$writeQueues->{'project'}->enqueue(join(',', ($projectName,$projectOwner,$projectPath)));

		# create the Project's Repositories
		csvGenericWalkerMultiThreaded('repository', sprintf($typeMap->{'repository'}->{'command'}, $projectName, $projectPath), 2, sub {
			my ($projectName,$repositoryName, $repositoryType, $repositoryPath) = @_;		
			
			$LOGGER->debug("RowVisitor(%s): ($projectName | $repositoryName | $repositoryType | $repositoryPath)", 'repository');

			$writeQueues->{'repository'}->enqueue(join(',', ($projectName,$repositoryName,$repositoryType,$repositoryPath)));

			# create Repository changesets
		 	csvGenericWalkerMultiThreaded('changeset', sprintf($typeMap->{'changeset'}->{'command'}, $repositoryName, $repositoryPath), 2, sub {
				my ($repository,$changeset,$developer,$file,$changes,$type,$module,$package,$class,$path) = @_;		
				
				$LOGGER->debug("RowVisitor(%s): %s", 'changeset', join(' | ', @_));

				$writeQueues->{'changeset'}->enqueue(join(',', ($repository,$changeset,$developer,$file,$changes,$type,$module,$package,$class,$path)));
			});

			# create Repository modules
		 	csvGenericWalkerMultiThreaded('module', sprintf($typeMap->{'module'}->{'command'}, $repositoryName, $repositoryPath), 2, sub {
				my ($repository,$module,$group, $path) = @_;		
				
				$LOGGER->debug("RowVisitor(%s): %s", 'module', join(' | ', @_));

				$writeQueues->{'module'}->enqueue(join(',', ($repository,$module,$group, $path)));
			});
		});
	});	
}

#
#  create a thread, and register it's log indent level.
#
sub createThread
{
	my ($function) = @_;

	my $parentId = threads->tid();
	my $thread = new Thread($function);
	my $childId = $thread->tid();
	$LOGGER->setThreadIndent($parentId, $childId);
	return $thread;
}
#
#  Monitor the write queues for each type, to make sure the file writes are fast enough.
#
sub monitorFileWriteQueue
{
	my ($writeQueues, $interval) = @_;

	# give the interval a default value
	$interval = (defined $interval ? $interval : 1);

	$LOGGER->debug(sprintf("---------------- Create a thread to monitor the write queues."));
	return createThread(sub {
		# break variable for while loop
		my $continue = 0;
		# listen for signal to break while loop
		$SIG{INT} = sub {$continue=1;};
		# monitoring loop
		while($continue == 0)
		{
			sleep $interval;
			# print the size of all of the queues.
			for my $type (keys %{$writeQueues})
			{
				my $size = $writeQueues->{$type}->pending();
				$LOGGER->debug(sprintf("---------------- Queue(%s) size: %d", $type, $size));
			}
		}
	});
}

#
#  #hutdown all of the write and monitoring threads, once all of the data has been processed.
#
sub closeFileWriteQueues
{
	my ($writeQueues, $writeToFileThreads, $monitorQueueThread) = @_;

	# add a terminator to the end of each queue
	$writeQueues->{$_}->enqueue(undef) for keys %{$writeQueues};

	# wait for all of the write threads to finish.
	$_->join() for @{$writeToFileThreads};

	$monitorQueueThread->kill('INT')->join() if (defined $monitorQueueThread);
}

#
#  Create write queues for each of the given types.
#  Many threads can write to a queue, and one thread reads from the queue, and writes to a file.
#
sub createFileWriteQueues
{
	my ($writeMode, $monitorInterval, $tmpDir, %typeMap) = @_;

	my %writeQueues = ();

	$writeQueues{$_} = new Thread::Queue() for keys %typeMap;

	my $monitorQueueThread;
	$monitorQueueThread = monitorFileWriteQueue(\%writeQueues) if ($monitorInterval > 0);

	# create all of the write to file threads.
	my @writeToFileThreads = ();
	for my $type (keys %typeMap)
	{
		my $writerProcess = sub {
			$LOGGER->debug("WriteProcessor($type): Getting write queue($type)\n");
			my $queue = $writeQueues{$type};
			
			my $file = sprintf("%s/%s.csv", $tmpDir, $type);
			my $fh;
			$LOGGER->debug("WriteProcessor($type): Opening output file($file)\n");
			open($fh, $writeMode, $file);
			
			# if in override, write header line
			if ($writeMode eq ">")
			{
				my $header = $typeMap{$type}->{'header'};
				print $fh $header . "\n";
			}

			# read from queue, and write into the file.
			my $line;
			while ($line = $queue->dequeue())
			{
				$LOGGER->debug("WriteProcessor($type): writing line: [$line]\n");
				print $fh $line . "\n";
				$fh->flush();
			}
			$LOGGER->debug("WriteProcessor($type): Closing output file($file)\n");
			close($fh);
			$LOGGER->debug("WriteProcessor($type): Writer Thread($file) has finished.\n");
		};

		$LOGGER->debug("WriteProcessor(): Creating Writer Thread(%s)",$type);

		push(@writeToFileThreads, createThread($writerProcess));
	}

	return  (\%writeQueues, \@writeToFileThreads, $monitorQueueThread);
}

#
# Read and process all of the lines from a given command.
# this will spawn a given number of threads to call a given RowVisitor, that is used to process the rows.
#
sub csvGenericWalkerMultiThreaded
{
	my ($type, $command, $noThreads, $rowVisitor) = @_;

	$LOGGER->debug("CommandExecutor(%s): About to walk output from command: $command", $type);

	# Queue for lines that need to be processed
	my $processingQueue = new Thread::Queue();

	# Processor for processing lines in the Processing Queue
	my $rowProcessor = sub {
		$LOGGER->debug("RowProcessor(%s): Starting to process records.", $type);
		my $line;
		while ($line = $processingQueue->dequeue())
		{
			my @values = split(',', $line);
			$LOGGER->debug("RowProcessor(%s): Processing line: %s", $type, $line);
			$rowVisitor->(@values);
		}
		$LOGGER->debug("RowProcessor(%s): Processing completed.", $type);
	};

	# create the processing threads.
	$LOGGER->debug("CommandExecutor(%s): Creating threads(%d) to process records.", $type, $noThreads);
	my @threads = ();
	push(@threads, createThread($rowProcessor)) for 1..$noThreads;
	#$LOGGER->debug("CommandExecutor(%s): Created RowProcessor[%d])", $type, $_->tid()) for (@threads);

	# processor for processing command output lines.
	my $outputProcessor = sub {
		$LOGGER->debug("OutputProcessor(%s): executing command: $command", $type);
	
		# execute a command, and create a file handle to read the output from.
		my $commandOutputPipe;
		my $commandPID = open($commandOutputPipe, "-|", "$command | head -3");

		$LOGGER->debug("OutputProcessor(%s): processing output: $command", $type);
		# read the command output line by line
		my $counter = 0	;
		while (<$commandOutputPipe>)
		{
			$counter++;

			my $line = $_;
			chomp($line);

			# add the line to the processing queue, to be handled by the child processing threads.
			$processingQueue->enqueue($line);

			$LOGGER->debug("OutputProcessor(%s): Added line to queue: %s", $type, $line);
		}
		# close the file handle use to read from the command output.
		close($commandOutputPipe);

		# inform each of the child threads that there us not going to be any more data.
		$processingQueue->enqueue(undef) for 1..$noThreads;

		$LOGGER->debug("OutputProcessor(%s): Waiting for child threads(%d) to finish.", $type, $noThreads);

		# wait for all of the child threads to finish.
		$_->join() for @threads;
	};

	# WIP: the following was used to test backgrounding all threads. 
	$LOGGER->debug("CommandExecutor(%s): Creating a thread to process output.", $type);
	\&$outputProcessor();
	#createThread($outputProcessor)->join();
}





#
#  Validate the Type Definition map, to make sure all of the configured commands are available.
#
sub validateTypeMap
{
	my (%typeMap) = @_;
    for my $type (keys %typeMap)
    {
    	if (defined $typeMap{$type}->{'command'})
    	{
	    	my $scriptString = $typeMap{$type}->{'command'};
	        my $script = (split(' ', $scriptString))[0];
	        die("Could not find script: $script") unless (-f "$script");
	    }
    }
}


1;