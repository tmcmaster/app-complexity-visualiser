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

my $parentGroup;
my $parentArtifact;
my $fh;
open($fh, "<", "$modulePath/target/dependency-tree.txt");
while (<$fh>)
{
	my $line = $_;
    chomp($line);

	if ($line =~ m/^digraph \"(.*?):(.*?):.*/)
	{
		$parentGroup = $1;
		$parentArtifact = $2;
	}
	elsif ($line =~ m/\s+\"(.*?):(.*?):.*\" -> \"(.*?):(.*?):.*\" ;/)
	{
		my $sourceGroup = $1;
		my $sourceArtifact = $2;
		my $targetGroup = $3;
		my $targetArtifact = $4;
		printf("%s,%s,%s,%s\n",$sourceArtifact,$sourceGroup,$targetArtifact,$targetGroup);
	}
	STDOUT->flush();
}
close($fh);