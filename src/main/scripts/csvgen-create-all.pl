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
#   module-class.csv   |  csvgen-module-class.pl [module] [modulePath]                 |  name(p) : group(p) : name(k) : package(k)
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

use threads;
use Thread;
use Thread::Queue;
use Getopt::Long;
use Pod::Usage;

use lib './lib';
use Complexity::Logger;
use Complexity::Util;

###################################################################################################################
#
#  Options Section
#


unless (-f "./csvgen-create-all.pl") { die "This script needs to be run from the script directory."};

my $type     = "project";
my $override = 0;
my $logLevel = 'DEBUG';
my $name;
my $path;
my $dryRun;
my $help;
my $man;

GetOptions ("type=s" => \$type,
            "name=s"   => \$name,
            "path=s"  => \$path,
            "log-level" => \$logLevel,
            "dry-run" => \$dryRun,
            "override" => \$override,
            "help|?" => \$help,
            "man" => \$man)
  			or die("Error in command line arguments\n");

pod2usage(1) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $man;

# print the options that are going to be used.
if ($dryRun)
{
	print "type        = $type\n";
	print "name        = $name\n";
	print "path        = $path\n";
	print "log-level = $logLevel\n";
	print "dry-run     = $dryRun\n";
	print "override    = $override\n";
	print "help        = $help\n";
	exit(0);
}


###################################################################################################################
#
#  Global Section
#

# create a logger to be used by this script, and any include libraries (part of this project only)

# tmp directory
my $tmpDir = sprintf("%s/tmp",$ENV{HOME});

# dev mode (0 normal, 1 testing mode)
my $devMode = 1;

# if there are already data files, add to the end of them, otherwise add a header line to the top of the files.
my $writeMode = (-f "$tmpDir/project.csv" && $devMode eq 0 ? ">>" : ">");

my $LOGGER = new Logger('csvgen-create-all','DEBUG');


###################################################################################################################
#
#  Definition Section
#


# WIP: metadata for each of the types
my %typeMap = (
	'project' => {
		'command' => "./csvgen-project.pl",
		'options' => [],
		'header' => "name,owner,path",
		'threads' => 2,
		'children' => [
			{
				'type' => 'repository',
				'params' => [0,2]
			}
		]
	},
	'repository' => {
		'command' => "./csvgen-repository.pl %s %s",
		'options' => [$name, $path],
		'header' => "project,name,type,path",
		'threads' => 2,
		'children' => [
			{
				'type' => 'changeset',
				'params' => [1,3]
			},
			{
				'type' => 'module',
				'params' => [1,3]
			}
		]
	},
	'changeset' => {
		'command' => "./csvgen-changeset.pl %s %s",
		'options' => [$name, $path],
		'header' => "repository,name,developer,file,changes,type,module,package,class,path",
		'threads' => 2
	},
	'module' => {
		'command' => "./csvgen-module.pl %s %s",
		'options' => [$name, $path],
		'header' => "repository,name,group,path",
		'threads' => 2,
		'children' => [
			{
				'type' => 'module-module',
				'params' => [1,3]
			},
			# {
			# 	'type' => 'module-class',
			# 	'params' => [1,3]
			# }
		]
	},
	'module-module' => {
		'command' => "./csvgen-module-module.pl %s %s",
		'options' => [$name, $path],
		'header' => "parent-name,parent-group,child-name,child-group,path",
		'threads' => 2
	},
	# 'module-class' => {
	# 	'command' => "./csvgen-module-class.pl %s %s",
	# 	'header' => "module-name,module-group,name,package,path",
	# 	'threads' => 2
	# }
);


###################################################################################################################
#
#  Validation Section
#


die "Could not find tmp directory: $tmpDir" unless (-d "$tmpDir");

validateTypeMap(%typeMap);

###################################################################################################################
#
#  Main Section
#

my @args = ();
push(@args, $name) if (defined $name);
push(@args, $path) if (defined $path);

$LOGGER->debug("So lets get started.");

# create file write queues and monitor them
my ($writeQueues, $writeToFileThreads) = createFileWriteQueues($writeMode, %typeMap);
#my $monitorQueueThread = monitorFileWriteQueue($writeQueues);

#analiseProjectVersionOne();
analiseProject(\%typeMap, $type, @{$typeMap{$type}->{'options'}});


# close the file write queues, and stop the queue monitoring
closeFileWriteQueues($writeQueues, $writeToFileThreads);
#closeFileWriteMonitoring($monitorQueueThread);

#$_->join() for threads->list();


###################################################################################################################
#
#  Function Section
#

sub analiseProject
{
	my ($typeMap, $type, @params) = @_;

	my $typeDef = $typeMap->{$type};
	my $command = sprintf($typeDef->{'command'}, @params);
	my $threads = $typeDef->{'threads'};

	printf("Command(%s)[%d]\n", $command, $threads);

	return unless ($type ==  'project');
	csvGenericWalkerMultiThreaded($type, $command, $threads, sub {

		$writeQueues->{$type}->enqueue(join(',', (@_)));

		for my $child (@{$typeDef->{'children'}})
		{
			if (defined $child->{'type'})
			{
				my $childType = $child->{'type'};
				#print "ChildType($childType)\n";
				my @params = @_[@{$child->{'params'}}];
				#printf("ParamsList(%s)\n", join(':', @params));
				analiseProject($typeMap, $childType, @params);
			}
		}
	});
}

sub analiseProjectVersionOne
{
	csvGenericWalkerMultiThreaded('project', sprintf($typeMap{'project'}->{'command'}), 2, sub {
		my ($projectName,$projectOwner,$projectPath) = @_;
		
		$LOGGER->debug("RowVisitor(%s): ($projectName | $projectOwner | $projectPath)", 'project');

		$writeQueues->{'project'}->enqueue(join(',', ($projectName,$projectOwner,$projectPath)));

		# create the Project's Repositories
		csvGenericWalkerMultiThreaded('repository', sprintf($typeMap{'repository'}->{'command'}, $projectName, $projectPath), 2, sub {
			my ($projectName,$repositoryName, $repositoryType, $repositoryPath) = @_;		
			
			$LOGGER->debug("RowVisitor(%s): ($projectName | $repositoryName | $repositoryType | $repositoryPath)", 'repository');

			$writeQueues->{'repository'}->enqueue(join(',', ($projectName,$repositoryName,$repositoryType,$repositoryPath)));

			# create Repository changesets
		 	csvGenericWalkerMultiThreaded('changeset', sprintf($typeMap{'changeset'}->{'command'}, $repositoryName, $repositoryPath), 2, sub {
				my ($repository,$changeset,$developer,$file,$changes,$type,$module,$package,$class,$path) = @_;		
				
				$LOGGER->debug("RowVisitor(%s): %s", 'changeset', join(' | ', @_));

				$writeQueues->{'changeset'}->enqueue(join(',', ($repository,$changeset,$developer,$file,$changes,$type,$module,$package,$class,$path)));
			});

			# create Repository modules
		 	csvGenericWalkerMultiThreaded('module', sprintf($typeMap{'module'}->{'command'}, $repositoryName, $repositoryPath), 2, sub {
				my ($repository,$module,$group, $path) = @_;		
				
				$LOGGER->debug("RowVisitor(%s): %s", 'module', join(' | ', @_));

				$writeQueues->{'module'}->enqueue(join(',', ($repository,$module,$group, $path)));
			});
		});
	});	
}

sub validateTypeMap
{
	my (%typeMap) = @_;
    for my $type (keys %typeMap)
    {
    	my $scriptString = $typeMap{$type}->{'command'};
        my $script = (split(' ', $scriptString))[0];
        die("Could not find script: $script") unless (-f "$script");
    }
}


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
	my ($writeMode, %typeMap) = @_;

	my %writeQueues = ();

	$writeQueues{$_} = new Thread::Queue() for keys %typeMap;

	# create all of the write to file threads.
	my @writeToFileThreads = ();
	for my $type (keys %typeMap)
	{
		printf("Creating Writer Thread(%s)\n",$type);

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

		push(@writeToFileThreads, new Thread($writerProcess));
	}

	return  (\%writeQueues, \@writeToFileThreads);
}

#
# Read in and process all of the lines from a given command.
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
	push(@threads, new Thread($rowProcessor)) for 1..$noThreads;
	$LOGGER->debug("CommandExecutor(%s): Created RowProcessor[%d])", $type, $_->tid()) for (@threads);

	# processor for processing command output lines.
	my $outputProcessor = sub {
		$LOGGER->debug("OutputProcessor(%s): executing command: $command", $type);
	
		# execute a command, and create a file handle to read the output from.
		my $commandOutputPipe;
		my $commandPID = open($commandOutputPipe, "-|", "$command | head -5");

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

	$LOGGER->debug("CommandExecutor(%s): Creating a thread to process output.", $type);
	\&$outputProcessor();
	#new Thread($outputProcessor)->join();
}

###################################################################################################################
#
#  Manual Section
#


#-----------------------------------------------------------------
#----------------  Documentation / Usage / Help ------------------
=head1 NAME

csvgen-create-all.pl - Project analiser.

=head1 SYNOPSIS

csvgen-create-all.pl [options]

=head1 OPTIONS

=over 8

=item B<--help>  

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--type>  

The type of entity to analise.

=item B<--name>  

The name of the entity to be analised.

=item B<--path>  

The path to the element to be analised.

=item B<--log-level>  

The log level to be used.

=item B<--dry-run>  

Don't do anything, just pring out the option values.

=item B<--override>  

Override the relationship CSV files.

=back

=head1 DESCRIPTION

Recursively analise project information, and generate CSV relationship data files.

=cut