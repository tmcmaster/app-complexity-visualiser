#!/usr/bin/perl

use lib './lib';
use Complexity::Logging;
use Log::Log4perl::Level;

###################################################################################################################
#
#  Options Section
#

if ($#ARGV > -1 && $ARGV[0] eq "--headers")
{
	print "name,owner,path\n";
}

unless (-f "./csvgen-create-all.pl") { die "This script needs to be run from the script directory."};

my $LOGGER = getOrCreateLogger('csvgen-project', $DEBUG);

my %projectMap = (
	"Libraries" => "Tim McMaster,/cygdrive/c/Users/Tim/Workspace/Mercurial/Libraries",
	"Apps" => "Tim McMaster,/cygdrive/c/Users/Tim/Workspace/Mercurial/Apps",
	"Alchemy" => "GraphAlchemist,/cygdrive/c/Users/Tim/Workspace/Clone/Alchemy",
	"betterFORM" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/betterFORM",
	"CodeMirror" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/CodeMirror",
	"eXist,TBD" => "/cygdrive/c/Users/Tim/Workspace/Clone/eXist",
	"javaparser" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/javaparser",
	"Jersey" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/Jersey",
	"Jetty" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/Jetty",
	"JointJS" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/JointJS",
	"XMLEditor" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/jquery.xmleditor",
	"Neo4j" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/Neo4j",
	"XULRunner-Example" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/XULRunner-Examples",
	"GetStuffDone" => "TBD,/cygdrive/c/Users/Tim/Workspace/Mercurial/Apps/get-stuff-done"
);

my @activeProjects = (
	#"Apps", 
	#"Libraries",
	"GetStuffDone", 
	"JointJS");

$LOGGER->debug('Creating Project list. Looking for projects.');
for my $projectName (@activeProjects)
{
	$projectLine = sprintf("%s,%s", $projectName, $projectMap{$projectName});
	my ($name, $owner, $path) = split(',', $projectLine);
	if (-d "$path")
	{
		print "$projectLine\n";
	}
}