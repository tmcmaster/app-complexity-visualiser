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

unless ($#ARGV > -1) { die "Project name is required." }
unless ($#ARGV > 0) { die "Project path is required." }

my $projectName = $ARGV[0];
my $projectPath = $ARGV[1];

my $LOGGER = getOrCreateLogger('csvgen-repository', $DEBUG);

my $csvGenRepository = "./project-repositories.pl";

unless (-f "$csvGenRepository") { die "Could not find script to generate projects: $csvGenRepository."};


###################################################################################################################
#
#  Main Section
#


$LOGGER->debug('Creating CSV data for Project list.');

if ($#ARGV > 1 && $ARGV[2] eq "--headers")
{
	print "project,name,type,path\n";
}

my $fh;
open($fh, "-|", "find $projectPath -name '.git' -o -name '.hg'");
while (<$fh>)
{
	my $path = $_;
    chomp($path);

    my ($baseDir, $relativePathDir, $name, $file) = splitPath($projectPath, $path);
    my $repositoryPath = ($relativePathDir eq "" ? $baseDir : sprintf("%s/%s",$baseDir,$relativePathDir));
    my $type = ($file eq ".hg" ? "Mercurial" : ($file eq ".git" ? "Git" : ""));
    printf("%s,%s,%s,%s\n", $projectName, $name, $type, $repositoryPath);
    STDOUT->flush();
}
close($fh);
