#!/usr/bin/perl

use strict;

use lib './lib';
use Complexity::Util;
use Complexity::Path;


#########################################################################################################
#
#  Main Section
#


my ($dir) = getDirectoryPlusArgs(@ARGV);
my $repository = getNameForPath($dir);

# print the parent record
printf("Repository,name,%s,path,%s,edge,CONTAINS\n", $repository, $dir);

# print the child records
if (-d "$dir/.hg")
{
    printChangesetsHg($dir);
}
elsif (-d "$dir/.git")
{
    printChangesetsGit($dir);
}
else
{
    die "Could not find repository: $dir";
}


#########################################################################################################
#
#  Function Section
#


sub printChangesetsHg
{
    my ($dir) = @_;

    for my $changeset (`(cd $dir; hg log --template "{date|shortdate}|{node|short}|{branch}|{author}\n")`)
    {
        chomp($changeset);

        my ($date,$changesetId,$branch,$developer) = split('\|',$changeset);

        my $developerString = parseDeveloperName($developer);
        printf("Changeset,name,%s,date,%s,branch,%s,developer,%s\n", $changesetId, $date, $branch, $developerString);
    }
}

sub printChangesetsGit
{
    my ($dir) = @_;

    my $changeset;
    my $developer;
    my $date;
    my $files;
    my $inserts;
    my $deletes;
    my $branch;
    my $commiter;
    for my $line (`cd $dir; git log --date=short --shortstat --oneline --format="%H | %an | %ad | %cn | %d |"`)
    {
        chomp($line);
        unless ($line =~ m/^$/)
        {
            #print "$line\n";
            if ($line =~ m/^ /)
            {
                ($files,$inserts,$deletes) = $line =~ m/\s+([0-9]*?) file changed, ([0-9]*?) insertions\(\+\), ([0-9]*?) deletions\(\-\)/;
            }
            else
            {
                printRecord($changeset,$date,$files,$inserts,$deletes,$developer,$branch);
                $files = 0;
                $inserts = 0;
                $deletes = 0;
                ($changeset,$developer,$date,$commiter,$branch) = $line =~ m/(.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \|/;
                $branch =~ s/,//g;                
            }
        }
    }
    printRecord($changeset,$date,$files,$inserts,$deletes,$developer,$branch);
}

sub printRecord
{
    my ($changeset,$date,$files,$inserts,$deletes,$developer,$branch) = @_;

    if (defined $changeset)
    {
        printf("Changeset,name,%s,date,%s,files,%d,inserts,%d,deletes,%d,developer,%s,branch,%s\n", $changeset,$date,$files,$inserts,$deletes,$developer,$branch)
    }
}
