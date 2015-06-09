#!/usr/bin/perl

use strict;

use lib './lib';
use Complexity::Logging;
use Log::Log4perl::Level;
use Complexity::Path;

###################################################################################################################
#
#  Options Section
#

unless (-f "./csvgen-create-all.pl") { die "This script needs to be run from the script directory."};

unless ($#ARGV > -1) { die "Repository name is required." }
unless ($#ARGV > 0) { die "Repository path is required." }

my $repositoryName = $ARGV[0];
my $repositoryPath = $ARGV[1];

my $LOGGER = getOrCreateLogger('csvgen-module', $DEBUG);


###################################################################################################################
#
#  Main Section
#


$LOGGER->debug('Creating CSV data for Module list for Repoisitory($repositoryName).');

if ($#ARGV > 1 && $ARGV[2] eq "--headers")
{
	print "repository,name,group,path\n";
}

my $fh;
open($fh, "-|", "find $repositoryPath -name pom.xml |egrep -v '\/build\/|\/target\/|\/.metadata\/'");
while (<$fh>)
{
	my $path = $_;
    chomp($path);

    my ($baseDir, $relativePathDir, $name, $file) = splitPath($repositoryPath, $path);
    my $modulePath = ($relativePathDir eq "" ? $baseDir : sprintf("%s/%s",$baseDir,$relativePathDir));
    my $type = ($file eq ".hg" ? "Mercurial" : ($file eq ".git" ? "Git" : ""));

    if (-f "$modulePath/target/dependency-tree.txt" && -d "$modulePath/src/main/java")
	{
		my $moduleLine = `head -1 $modulePath/target/dependency-tree.txt`;
		chomp($moduleLine);
		my ($group,$name) = $moduleLine =~ m/^digraph \"(.*?):(.*?):.*/;
		printf("%s,%s,%s,%s\n",$repositoryName,$name,$group,$modulePath);
	}
    STDOUT->flush();
}
close($fh);