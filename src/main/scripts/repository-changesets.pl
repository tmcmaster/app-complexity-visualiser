#!/usr/bin/perl

use strict;

use lib './lib';
use Complexity::Util;
use Complexity::Path;
use JSON::Parse;

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

        my $statsLine = `(cd $dir; hg log --stat -r $changesetId |tail -2 |head -1)`;
        chomp($statsLine);
        my $files = ($statsLine =~ m/([0-9]*?) file[s]* changed/ ? $1 : 0);
        my $inserts = ($statsLine =~ m/([0-9]*?) insertion[s]*/ ? $1 : 0);
        my $deletes = ($statsLine =~ m/([0-9]*?) deletion[s]*/ ? $1 : 0);

        printRecord($changesetId,$date,$files,$inserts,$deletes,$developer,$branch);
        #printf("Changeset,name,%s,date,%s,branch,%s,developer,%s\n", $changesetId, $date, $branch, $developerString);
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
                $files = ($line =~ m/([0-9]*?) file[s]* changed/ ? $1 : 0);
                $inserts = ($line =~ m/([0-9]*?) insertion[s]*/ ? $1 : 0);
                $deletes = ($line =~ m/([0-9]*?) deletion[s]*/ ? $1 : 0);

                #($files,$inserts,$deletes) = $line =~ m/\s+([0-9]*?) file[s]* changed, ([0-9]*?) insertion[s]*\(\+\), ([0-9]*?) deletion[s]*\(\-\)/;
                #print "---- Found changes: [$line]: $files,$inserts,$deletes\n";
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
        printf("Changeset,name,%s,date,%s,files,%d,inserts,%d,deletes,%d,changes,%s,developer,%s,branch,%s,edge,\n", $changeset,$date,$files,$inserts,$deletes,$inserts+$deletes,$developer,$branch)
    }
}
