#!/usr/bin/perl

use strict;

use lib './lib';

use Complexity::Util;
use Complexity::Path;

my ($dir) = getDirectoryPlusArgs(@ARGV);
my $project = getNameForPath($dir);

my $command;

if (-d "$dir/.hg")
{
    $command = 'hg log --template "{author}\n" |iconv -t utf-8 -c |sort |uniq';
}
elsif (-d "$dir/.git")
{
    $command = 'git log --oneline  --format="%an" |iconv -t utf-8 -c |sort |uniq';
}
else
{
    die "Could not find repository: $dir";
}

my %developerMap = ();

print "Repository,name,$project,path,$dir\n";
for my $developer (`(cd $dir; $command)`)
{
    chomp($developer);

    my $developerString = parseDeveloperName($developer);
    unless ($developerMap{$developerString})
    {
        $developerMap{$developerString} = 1;
        printf("Developer,name,%s\n", $developerString);
    }
}

