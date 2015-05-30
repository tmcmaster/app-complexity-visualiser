#!/usr/bin/perl
#
# Load file to change action map
# git log --name-status --format=""  -1 1c5a1dd37f2579278a491a27114ceed16eee59fe
#
# Get inserts and deletes
# git log --numstat --pretty=""  -1 c6b127d94816207f57412cf2290cc44eca6aaa46
#
# Load changeset details
# git log --date=short --format="%H | %an | %ad | %cn | %d" 5d26e0271e5b9c12171f03a89e633a75ad723ec8 -1
#
# This gives supplies all of the required information
# git log  --shortstat --oneline -1 --format="%H | %an | %ad | %cn | %d" 5d26e0271e5b9c12171f03a89e633a75ad723ec8

use strict;

my $dir;
my $changeset;

if ($#ARGV > -1)
{
	$dir = $ARGV[0];
	if ($#ARGV > 0)
	{
		$changeset = $ARGV[1];
	}
}
else
{
	$dir = `pwd`;
	chomp($dir);
	if ($#ARGV > -1)
	{
		$changeset = $ARGV[0];
	}
}

unless (-d $dir)
{
	die "Given directory was invalid: $dir";
}

unless (defined $changeset)
{
	die "Changeset is required.";
}

my %fileStatsMap = ();
for my $line (`cd $dir; git log --name-status --format=""  -1 $changeset`)
{
	chomp($line);
	my ($action, $file) = $line =~ m/([MAR])\s+(.*)/;
	my %fileStats = ('action' => $action);
	$fileStatsMap{$file} = \%fileStats;
}

for my $line (`cd $dir; git log --numstat --format=""  -1 $changeset`)
{
	chomp($line);
	my ($inserts, $deletes, $file) = $line =~ m/([0-9]*)\s+([0-9]*)\s+(.*)/;
	my $stats = $fileStatsMap{$file};
	$stats->{'inserts'} = $inserts;
	$stats->{'deletes'} = $deletes;
}

printf("Changeset,name,%s\n", $changeset);
for my $file (keys %fileStatsMap)
{
	my $stats = $fileStatsMap{$file};
	my ($path,$name) = $file =~ m/(.*)\/(.*)/;
	printf("File,name,%s,path,%s,action,%s,inserts,%s,deletes,%s\n", $name, $path, $stats->{'action'}, $stats->{'inserts'}, $stats->{'deletes'});
}