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
use Complexity::Import;
use Complexity::Analyse;


###################################################################################################################
#
#  Options Section
#


unless (-f "./csvgen-create-all.pl") { die "This script needs to be run from the script directory."};

my $type     = "project";
my $override = 0;
my $logLevel = 'DEBUG';
my $logIndent = 0;
my $name;
my $path;
my $projectOwner;
my $projectList;
my $projectAll;
my $outputDir;
my $genData = 0;
my $genCypher;
my $genAll = 0;
my $import = 0;
my $dryRun = 0;
my $monitorInterval = 0,
my $help = 0;
my $man = 0;

GetOptions ("type=s"           => \$type,
            "name=s"           => \$name,
            "path=s"           => \$path,
            "owner=s"          => \$projectOwner,
            "list"             => \$projectList,
            "all"              => \$projectAll,
            "output-dir:s"     => \$outputDir,
            "log-level:s"      => \$logLevel,
            "log-indent"       => \$logIndent,
            "dry-run"          => \$dryRun,
            "override"         => \$override,
            "gen-cypher"       => \$genCypher,
            "gen-data"         => \$genData,
            "gen-all"          => \$genAll,
            "import"           => \$import,
            "monitor-queues:i" => \$monitorInterval,
            "help|?"           => \$help,
            "man"              => \$man)
  			or die("Error in command line arguments\n");

pod2usage(1) if $help && !$dryRun;
pod2usage(-exitval => 0, -verbose => 2) if $man && !$dryRun;

# print the options that are going to be used.
if ($dryRun)
{
	print "\nSelected Options:\n";
	print "--------------------------------------------------------\n\n";
	print "  type           = $type\n";
	print "  name           = $name\n";
	print "  path           = $path\n";
	print "  owner          = $projectOwner\n";
	print "  list           = $projectList\n";
	print "  all            = $projectAll\n";
	print "  output-dir     = $outputDir\n";
	print "  log-level      = $logLevel\n";
	print "  log-indent     = $logIndent\n";
	print "  dry-run        = $dryRun\n";
	print "  override       = $override\n";
	print "  gen-cypher     = $genCypher\n";
	print "  gen-data       = $genData\n";
	print "  gen-all        = $genAll\n";
	print "  import         = $import\n";
	print "  monitor-queues = $monitorInterval\n";
	print "  help           = $help\n";
	print "  man            = $man\n";
}

###################################################################################################################
#
#  Global Section
#

# create a logger to be used by this script, and any include libraries (part of this project only)

my @defaultOutputDirectories = ("/cygdrive/c/Users/Tim/Workspace/Neo4j/scratch", "/cygdrive/d/work/neo4j/scratch");

# project arguments
my $projectArguments = generateProjectArguments($type, $name, $projectOwner, $path, $projectList, $projectAll);
# tmp directory
my $tmpDir = determineOutputDirectory($outputDir, @defaultOutputDirectories);

# if there are already data files, add to the end of them, otherwise add a header line to the top of the files.
my $writeMode = ($override eq 1 ? ">" : ">>");

my $LOGGER = new Logger('csvgen-create-all',$logLevel,$logIndent);

#print "ProjectArguments($projectArguments)\n"; exit(0);

###################################################################################################################
#
#  Definition Section
#

print "projectArguments = [$projectArguments]\n";

#
# Metadata for each of the types.
#
# - The main key to the map is the entity type.
# - Subkeys:
#   - command: the command to run to find all of the entities of the particular type.
#   - opyions:
#
my %typeMap = (
	'project' => {
		'alias' => "p",
		'command' => "./csvgen-project.pl %s",
		'options' => [$projectArguments],
		'threads' => 2,
		'header' => "name,owner,path",  # need to deprecate
		'columns' => {
			'headings' => ['name','owner','path'],
			'keys' => ['name'],
			'props' => ['owner','path']
		},
		'children' => [
			{
				'type' => 'repository',
				'params' => [0,2]
			}
		]
	},
	'repository' => {
		'alias' => "r",
		'command' => "./csvgen-repository.pl %s %s",
		'options' => [$name, $path],
		'threads' => 2,
		'header' => "project,name,type,path", # need to deprecate
		'columns' => {
			'headings' => ['project','name','type','path'],
			'keys' => ['name'],
			'props' => ['type','path'],
			'parent' => {
				'keys' => ['name:project'],
				'props' => [],
				'relationship' => {
					'parent-row' => "CONTAINS",
					'row-parent' => "BELONGS_TO"
				}				
			}
		},
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
		'alias' => "c",
		'command' => "./csvgen-changeset.pl %s %s",
		'options' => [$name, $path],
		'threads' => 2,
		'header' => "repository,name,date,developer", # need to deprecate
		'columns' => {
			'headings' => ['repository','name','date', 'developer'],
			'keys' => ['name'],
			'props' => ['date', 'developer'],
			'parent' => {
				'type' => 'repository',
				'keys' => ['name:repository'],
				'props' => [],
				'relationship' => {
					'parent-row' => "CONTAINS",
					'row-parent' => "BELONGS_TO"
				}				
			},
			'children' => [
				{
					'type' => "developer",
					'keys' => ['name:developer'],
					'props' => [],
					'relationships' => {
						'row-child' => "CREATED_BY",
						'child-row' => "CREATED"
					}
				}
			]
		},
		'children' => [
			{
				'type' => 'changeset-file',
				'parent-params' => 1,
				'params' => []
			}
		]
	},
	'developer' => {
		'alias' => "d",
	},
	'file' => {
		'alias' => "f",
	},
	'changeset-file' => {
		'alias' => "f",
		'command' => "./csvgen-changeset-file.pl %s %s",
		'options' => [$name, $path],
		'header' => "repository,changeset,name,changes,type,module,package,class,path", # need to deprecate
		'threads' => 2,
		'columns' => {
			'headings' => ['repository','changeset', 'name','changes','type','module','package','class','path'],
			'keys' => ['path'],
			'props' => ['changes','type','module','package','class'],
			'parent' => {
				'type' => "changeset",
				'keys' => ['name:changeset'],
				'props' => [],
				'relationship' => {
					'parent-row' => "CHANGED",
					'row-parent' => "CHANGED_BY",
				}
			}
		}
	},
	'module' => {
		'alias' => "m",
		'command' => "./csvgen-module.pl %s %s",
		'options' => [$name, $path],
		'header' => "repository,name,group,path", # need to deprecate
		'threads' => 2,
		'columns' => {
			'headings' => ['repository','name','group','path'],
			'keys' => ['name','group'],
			'props' => ['path'],
			'parent' => {
				'type' => "repository",
				'keys' => ['name:repository'],
				'props' => [],
				'relationship' => {
					'parent-row' => "CONTAINS",
					'row-parent' => "BELONGS_TO",
				}
			}
		},
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
		'alias' => "mm",
		'command' => "./csvgen-module-module.pl %s %s",
		'options' => [$name, $path],
		'header' => "pname,pgroup,name,group,path", # need to deprecate
		'threads' => 2,
		'columns' => {
			'headings' => ['pname','pgroup','name','group','path'],
			'keys' => ['name','group'],
			'props' => ['path'],
			'parent' => {
				'type' => "module",
				'keys' => ['name:pname','group:pgroup'],
				'props' => [],
				'relationship' => {
					'parent-row' => "REFERENCES",
					'row-parent' => "REFERENCED_BY",
				}
			}
		},
	},
	# 'module-class' => {
	# 	'command' => "./csvgen-module-class.pl %s %s",
	# 	'header' => "module-name,module-group,name,package,path",
	# 	'threads' => 2,
	# 	'columns' => {
	# 		'headings' => ['module-name','module-group','name','package','path'],
	# 		'keys' => ['path'],
	# 		'props' => ['name', 'package'],
	# 		'parent' => {
	# 			'type' => "module",
	# 			'keys' => ['name:module-name','group:module-group'],
	# 			'props' => [],
	# 			'relationships' => {
	# 				'parent-row' => "CONTAINS",
	# 				'row-parent' => "BELOMGS_TO",
	# 			}
	# 		}
	# 	},
	# }
);


###################################################################################################################
#
#  Validation Section
#

# print calculated options if in dry t
if ($dryRun)
{
	print "  tmpDir         = $tmpDir\n";
	print "  progArgs       = $projectArguments\n";
	print "  writeMode      = $writeMode\n";
	print "\n--------------------------------------------------------\n\n";
}

die "Could not determine the output directory." unless (defined $tmpDir);
die "The select output directory was not there." unless (-d "$tmpDir");

validateTypeMap(%typeMap);

# exit if in dry run mode.
exit(0) if ($dryRun);

###################################################################################################################
#
#  Main Section
#

$LOGGER->debug("Main(%s): So lets get started.", $type);

if ($genCypher || $genAll)
{
	generateCypherImportFiles(\%typeMap, $tmpDir, $type);
}

if ($genData || $genAll)
{
	# create file write queues and monitor them
	my ($writeQueues, $writeToFileThreads, $monitorQueueThread) = createFileWriteQueues($writeMode, $monitorInterval, $tmpDir, %typeMap);

	#analiseProjectVersionOne($writeQueues);
	analiseProject(\%typeMap, $type, $writeQueues, @{$typeMap{$type}->{'options'}});

	# close the file write queues, and stop the queue monitoring
	closeFileWriteQueues($writeQueues, $writeToFileThreads, $monitorQueueThread);
}


$LOGGER->debug("Main(%s): Job well done.", $type);


###################################################################################################################
#
#  Function Section
#


sub generateProjectArguments
{
	my ($type, $name, $owner, $path, $list, $all) = @_;

	unless ($type eq "project")
	{
		return "";
	}
	else
	{
		my $args = "";
		$args .= " --all" if (defined $all);
		$args .= " --list" if (defined $list);
		$args .= " --name $name" if (defined $name);
		$args .= " --owner $owner" if (defined $owner);
		$args .= " --path $path" if (defined $path);
		$args =~ s/^ //;
		return $args;
	}
}

sub determineOutputDirectory
{
	my ($outputDir, @possibleDefaults) = @_;

	unless (defined $outputDir)
	{	
		for my $dir (@possibleDefaults)
		{
			$outputDir = $dir if (-d $dir);
		}
	}

	return $outputDir;
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

=item B<--owner>  

(type = project) the owner of the project to be analised.

=item B<--list>  

(type = project) supply a list of project to be analised.

=item B<--all>  

(type = project) analise all of the registered projects.

=item B<--log-level>  

The log level to be used.

=item B<--log-level>  

Indent logs based on thread hierachy.

=item B<--dry-run>  

Don't do anything, just print out the option values.

=item B<--override>  

Override the relationship CSV files.

=item B<--gen-cypher>

Generate the data import cyphers.

=item B<--gen-data>

Generate the anaysis data.

=item B<--gen-all>

Generate both data and import cyphers, and import data into the neo4j database.

=item B<--import>

Import current data into the Neo4j database.

=item B<--monitor-queues>

Switch on write queue monitoring, supplying the polling interval in seconds.

=back

=head1 DESCRIPTION

Recursively analise project information, and generate CSV relationship data files.

=cut