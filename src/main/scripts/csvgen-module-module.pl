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

unless ($#ARGV > -1) { die "Module name is required." }
unless ($#ARGV > 0) { die "Module path is required." }

my $moduleName = $ARGV[0];
my $modulePath = $ARGV[1];

my $LOGGER = getOrCreateLogger('csvgen-module-module', $DEBUG);


###################################################################################################################
#
#  Main Section
#


$LOGGER->debug('Creating CSV data for Module list for Module($moduleName).');

if ($#ARGV > 1 && $ARGV[2] eq "--headers")
{
	print "parent-name,parent-name,child-name,child-group\n";
}

my $sourceGroup;
my $sourceArtifact;
my $fh;
open($fh, "<", "$modulePath/target/dependency-tree.txt");
while (<$fh>)
{
	my $line = $_;
    chomp($line);

	if ($line =~ m/^digraph \"(.*?):(.*?):.*/)
	{
		$sourceGroup = $1;
		$sourceArtifact = $2;
	}
	elsif ($line =~ m/.*\" -> \"(.*?):(.*?):.*/)
	{
		my $targetGroup = $1;
		my $targetArtifact = $2;
		printf("%s,%s,%s,%s\n",$sourceArtifact,$sourceGroup,$targetArtifact,$targetGroup);
	}
	STDOUT->flush();
}
close($fh);