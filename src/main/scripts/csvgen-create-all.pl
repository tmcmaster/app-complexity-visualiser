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
#  File Write Queue Section
#
#  Many threads can write to a queue, and one thread reads from the queue, and writes to a file.
#

my %writeQueues = (
	'project' => new Thread::Queue(),
	'repository' => new Thread::Queue()
);


# create all of the write to file threads.
my @writeToFileThreads = ();
for my $type (keys %writeQueues)
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



###################################################################################################################
#
#  Main Section
#

$LOGGER->debug("So lets get started.");

createProjectCSV();

# and a terminator to the end of each queue
$writeQueues{$_}->enqueue(undef) for keys %writeQueues;

# wait for all of the write threads to finish.
$_->join() for @writeToFileThreads;


###################################################################################################################
#
#  Function Section
#


sub createProjectCSV
{
	$LOGGER->info("Creating Projects.");

	# load projects
	csvGenericWalkerMultiThreaded($cvsGenProject, $headers, 'project', 3, sub {
		my ($projectName,$projectOwner,$projectPath) = @_;
		
		$LOGGER->debug("ProcessingProject($projectName | $projectOwner | $projectPath)");

		# create the Project's Repositories
		createRepositoryCSV($projectName, $projectPath);
	});
}

sub createRepositoryCSV
{
	my ($projectName, $projectPath) = @_;

	$LOGGER->debug("Creating repositories for Project: ProjectName($projectName), ProjectPath($projectPath)");

	csvGenericWalkerMultiThreaded(sprintf($cvsGenRepository, $projectName, $projectPath), $headers, 'repository', 2, sub {
		my ($projectName,$repositoryName, $repositoryType, $repositoryPath) = @_;		
		$LOGGER->debug("ProcessingRepository($projectName | $repositoryName | $repositoryType | $repositoryPath)");
	});
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
			$LOGGER->debug(sprintf("Queue(%d): Processing line: %s\n", $processingQueue->pending(), $line));
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

	# write queue, for persiting the CSV Table Data (ctd) into a file
	my $writeQueue = $writeQueues{$type};
	
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
		if ($headers eq "--headers" && $counter == 1)
		{
			# queue the header line to be writen to the output file
			$writeQueue->enqueue($line);
		}
		else
		{
			sleep 1 while ($writeQueue->pending() > $queueSize || $processingQueue->pending() > $queueSize);
			
			# queue the header line to be writen to the output file
			$writeQueue->enqueue($line);

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

#
# Execute a process that outputs CSV data, optionally with a header line, and walk the raulting data.
# 
# sub csvGenericWalker
# {
# 	my ($command, $headers, $rowVisitor, $headerVisitor) = @_;

# 	$LOGGER->debug("About to walk output from command: $command $headers");

# 	my $fh;
# 	open($fh, "$command $headers |");

# 	my @threads = ();
# 	my $counter = 0;
# 	while (<$fh>)
# 	{	
# 		$counter++;

# 		# split the current line into values
# 		my $line = $_;
# 		chomp($line);
# 		my @values = split(',', $line);
# 		printf("[%s][%s][%s]\n", $values[0],$values[1],$values[2]);

# 		if ($headers eq "--headers" && $counter == 1)
# 		{
# 			$headerVisitor->(@values);
# 		}
# 		else
# 		{
# 			push(@threads, threads->new($rowVisitor, @values));
# 			#$rowVisitor->(@values);
# 		}
# 	}

# 	$_->join foreach @threads;

# 	close($fh);
# }