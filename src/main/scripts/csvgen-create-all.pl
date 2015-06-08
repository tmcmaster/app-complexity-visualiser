#!/usr/bin/perl
#
#  Guidelines:
#
# - parent entity foreign keys at the start
# - then name of entity
# - then attributes of entity
# - then child entity foreign key 
# - then child entity relationship properties
#
# - name is used default entity display
# - path is relative to parent path
#
# - primary key is name and optionally othere properties.
# - below primary keys are suffixed by (k)
# - parent foreign keys are suffixed by (p)
# - child foreign keys are suffixed by (c)
#
# - csvgen scripts should output to STDOUT
# - csvgen scripts should only print header line with option --headers
# - this will enable concatination to the end of the csv files
# 
#  CSV Files to be created:
#
#   project.csv        |  csvgen-project.pl                                            |  name(k) : owner : path
#   repository.csv     |  csvgen-repository.pl [project] [projectPath]                 |  project(p) : name(k) : type : path
#   module.csv         |  csvgen-module.pl [repository] [repositoryPath]               |  repository(p) : name(k) : path
#   changeset.csv      |  csvgen-changeset.pl [repository] [repositoryPath]            |  repository(p) : name(k) : file : developer : changes : type : modeule : package : class : path
#   module-module.csv  |  csvgen-module-module.pl [module] [modulePath]                |  name(p) : group(p) : name(k) : group(k)
#   class-class.csv    |  csvgen-class-class.pl [module] [package] [class] [filePath]  |  module(p) : package(p) : class(p) : module(k) : package(k) : class(k)
#
#  Output Directory is $HOME/tmp
#
#  WIP:  Ther following are some ideas for documenting processes:
#  WIP:  Database >- Script (script reads data from a database)
#  WIP:  Script A -> CDV Data >- Script B -> Database (Script A generates CSV Data. Script B reads CSV Data, and writes it into a database)
#  
#  WIP:  Natral Data -> CSV Relationship Data (crd) -> CSV Table Data (ctd) >- Cypher Query Language (cql) -> Neo4j
#  
#  CRD File Format (comma separated)
#    - First line: Parent Type, key1, value1, key2, value2..., edge, Relationship Type, relKey1, relValue1, relKey2, relValue2... 
#    - Subsequent Lines: Child Type, value1, key2, value2..., edge, relKey1, relValue1, relKey2, relValue2...
#
#  TODO
#
#  - Add multithreading where needed.


###################################################################################################################
#
#  Use Section
#


use strict;

# use Log::Log4perl qw(:easy);
use Log::Log4perl;
use Log::Log4perl::Layout;
use Log::Log4perl::Level;
use threads;
use Thread;
use Thread::Queue;

use lib './lib';
use Complexity::Logging;
my $LOGGER = createLogger("csvgen-create-all", $DEBUG);
use Complexity::Util;


###################################################################################################################
#
#  Options Section
#


unless (-f "./csvgen-create-all.pl") { die "This script needs to be run from the script directory."};


###################################################################################################################
#
#  Global Section
#

# create a logger to be used by this script, and any include libraries (part of this project only)

# tmp directory
my $tmpDir = sprintf("%s/tmp",$ENV{HOME});

my $devMode = 1;

# if there are already data files, add to the end of them, otherwise add a header line to the top of the files.
my $headers = ($devMode eq 1 ? "--headers" : (-f "$tmpDir/project.csv" ? "" : "--headers"));
my $writeMode = ($headers eq "" ? ">>" : ">");

# CSV files
my $projectCSV = sprintf("%s/project.csv", $tmpDir);
my $repositoryCSV = sprintf("%s/repository.csv", $tmpDir);

# CSV generation scripts
my $cvsGenProject = "./csvgen-project.pl";
my $cvsGenRepository = "./csvgen-repository.pl %s %s";  # [project] [projectPath]

###################################################################################################################
#
#  Validation Section
#

logdie("Could not find tmp directory: $tmpDir") unless (-d "$tmpDir");

validateScripts($cvsGenProject, $cvsGenRepository);


###################################################################################################################
#
#  Main Section
#

$LOGGER->debug("So lets get started.");

# create file write queues and monitor them
my ($writeQueues, $writeToFileThreads) = createFileWriteQueues('project', 'repository');
my $monitorQueueThread = monitorFileWriteQueue($writeQueues);

csvGenericWalkerMultiThreaded(sprintf('./csvgen-project.pl'), $headers, 'project', 1, sub {
	my ($projectName,$projectOwner,$projectPath) = @_;
	
	$LOGGER->debug("---- ProcessingProject($projectName | $projectOwner | $projectPath) ----");

	$writeQueues->{'project'}->enqueue(join(',', ($projectName,$projectOwner,$projectPath)));

	# create the Project's Repositories
	csvGenericWalkerMultiThreaded(sprintf('./csvgen-repository.pl %s %s', $projectName, $projectPath), $headers, 'repository', 3, sub {
		my ($projectName,$repositoryName, $repositoryType, $repositoryPath) = @_;		
		
		$LOGGER->debug("---- ProcessingRepository($projectName | $repositoryName | $repositoryType | $repositoryPath) ----");

		$writeQueues->{'repository'}->enqueue(join(',', ($projectName,$repositoryName,$repositoryType,$repositoryPath)));

	});
});

# close the file write queues, and stop the queue monitoring
closeFileWriteQueues($writeQueues, $writeToFileThreads);
closeFileWriteMonitoring($monitorQueueThread);

###################################################################################################################
#
#  Function Section
#

sub monitorFileWriteQueue
{
	my ($writeQueues, $interval) = @_;

	# give the interval a default value
	$interval = (defined $interval ? $interval : 1);

	$LOGGER->debug(sprintf("---------------- Create a thread to monitor the write queues."));
	return new Thread(sub {
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

sub closeFileWriteMonitoring
{
	my ($thread) = @_;

	$thread->kill('INT')->join();
}

sub closeFileWriteQueues
{
	my ($writeQueues, $writeToFileThreads) = @_;

	# add a terminator to the end of each queue
	$writeQueues->{$_}->enqueue(undef) for keys %{$writeQueues};

	# wait for all of the write threads to finish.
	$_->join() for @{$writeToFileThreads};
}

#
#  Create write queues for each of the given types.
#  Many threads can write to a queue, and one thread reads from the queue, and writes to a file.
#
sub createFileWriteQueues
{
	my (@typeList) = @_;

	my %writeQueues = ();

	$writeQueues{$_} = new Thread::Queue() for @typeList;

	# create all of the write to file threads.
	my @writeToFileThreads = ();
	for my $type (@typeList)
	{
		printf("Creating Writer Thread(%s)\n",$type);
		push(@writeToFileThreads, new Thread(sub {
			$LOGGER->debug("Getting write queue($type)\n");
			my $queue = $writeQueues{$type};
			
			my $file = sprintf("%s/%s.csv", $tmpDir, $type);
			my $fh;
			$LOGGER->debug("Opening output file($file)\n");
			open($fh, $writeMode, $file);
			my $line;
			while ($line = $queue->dequeue())
			{
				$LOGGER->debug("----- [$line]\n");
				print $fh $line . "\n";
			}
			$LOGGER->debug("Closing output file($file)\n");
			close($fh);
			$LOGGER->debug("Writer Thread($file) has finished.\n");
		}));
	}

	return  (\%writeQueues, \@writeToFileThreads);
}

#
# Read in and process all of the lines from a given command.
#
sub csvGenericWalkerMultiThreaded
{
	my ($command, $headers, $type, $noThreads, $rowVisitor) = @_;

	$LOGGER->debug("About to walk output from command: $command $headers");

	# Queue for lines that need to be processed
	my $processingQueue = new Thread::Queue();

	# Processor for processing lines in the Processing Queue
	my $processor = sub {
		$LOGGER->debug("Starting to process $type records.");
		my $line;
		while ($line = $processingQueue->dequeue())
		{
			my @values = split(',', $line);
			$LOGGER->debug(sprintf("Queue(%s) Pending(%d): Processing line: %s\n", $type, $processingQueue->pending(), $line));
			$rowVisitor->(@values);
		}
		$LOGGER->debug("Processing completed.");
	};

	# set the maximum size the Processing Queue can be. 
	my $queueSize = 2;

	# create the processing threads.
	$LOGGER->debug("Creating threads.");
	my @threads;
	push @threads, new Thread($processor) for 1..$noThreads;

	# execute a command, and create a file handle to read the output from.
	my $commandOutputPipe;
	my $commandPID = open($commandOutputPipe, "$command $headers |");

	# read the command output line by line
	my $counter = 0	;
	while (<$commandOutputPipe>)
	{
		$counter++;

		my $line = $_;
		chomp($line);

		# if headers is turned on and is a header line, process the header line
		if ($headers eq "" || $counter > 1)
		{
			# add the line to the processing queue, to be handled by the child processing threads.
			$processingQueue->enqueue($line);

			$LOGGER->debug(sprintf("Added line into the write and processing queues: %s\n", $line));
		}
	}
	# close the file handle use to read from the command output.
	close($commandOutputPipe);

	# inform each of the child threads that there us not going to be any more data.
	$processingQueue->enqueue(undef) for 1..$noThreads;

	# wait for all of the child threads to finish.
	$_->join() for @threads;
}
