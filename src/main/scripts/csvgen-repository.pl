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

my $fh;
open($fh, "-|", "find $projectPath -name '.git' -o -name '.hg'");
while (<$fh>)
{
	my $path = $_;
    chomp($path);

    my ($baseDir, $relativePathDir, $name, $file) = splitPath($projectPath, $path);
    my $type = ($file eq ".hg" ? "Mercurial" : ($file eq ".git" ? "Git" : ""));
    printf("%s,%s,%s,%s\n", $projectName, $name, $type, $relativePathDir);
    STDOUT->flush();
}
close($fh);
