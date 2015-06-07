#!/usr/bin/perl

use strict;

use lib './lib';
#use Complexity::Util;
use Complexity::Logging;
use Log::Log4perl::Level;

###################################################################################################################
#
#  Options Section
#

if ($#ARGV > -1 && $ARGV[0] eq "--headers")
{
	print "project,name,type,path\n";
}

unless (-f "./csvgen-create-all.pl") { die "This script needs to be run from the script directory."};

unless ($#ARGV > -1) { die "Project name is required." }
unless ($#ARGV > 0) { die "Project path is required." }

my $projectName = $ARGV[0];
my $projectPath = $ARGV[1];

my $LOGGER = getOrCreateLogger('csvgen-repository', $DEBUG);

my $csvGenRepository = "./project-repositories.pl";

unless (-f "$csvGenRepository") { die "Could not find script to generate projects: $csvGenRepository."};

$LOGGER->debug('Creating CSV data for Project list.');

my $count = 0;
for my $line (`$csvGenRepository $projectPath`)
{
	chomp($line);

}