#!/usr/bin/perl

use strict;

my $changeset;
if ($#ARGV eq -1)
{
	die "Changeset required.";
}
else
{
	$changeset = $ARGV[0];
}

my @results = `hg status --change $changeset`;

printf("Changeset,%s\n", $changeset);
my $line;
for $line (@results)
{
    chomp($line);
    my ($action, $file) = $line =~ m/([ARM])? (.*)/;

    $file =~ s/\\/\//g;
    if ($action == "A" || $action == "R" || $action == "M")
    {
        my $statsResult = `hg log --stat -r $changeset $file |tail -2 |head -1`;
        chomp($statsResult);
        my ($inserts,$deletes) = $statsResult =~ m/[0-9]* files changed, ([0-9]*) insertions\(\+\), ([0-9]*) deletions\(\-\)/;
        printf("File,name,%s,action,%s,inserts,%s,deletes,%s\n", $file, $action, $inserts, $deletes);
    }
}
