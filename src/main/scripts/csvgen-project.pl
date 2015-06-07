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

my @projectList = (
	"Libraries,Tim McMaster,/cygdrive/c/Users/Tim/Workspace/Mercurial/Libraries",
	"Libraries,Tim McMaster,/cygdrive/c/Users/Tim/Workspace/Mercurial/Apps"
);

$LOGGER->debug('Creating Project list.');
for my $projectLine (@projectList)
{
	print "$projectLine\n";
}