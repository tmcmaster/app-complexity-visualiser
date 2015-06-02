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

use lib './lib';
use Complexity::Util;
use Complexity::Path;


#########################################################################################################
#
#  Options Section
#


my ($dir, $changeset) = getDirectoryPlusArgs(@ARGV);
my $repository = getNameForPath($dir);

unless (defined $changeset)
{
	die "Changeset is required.";
}


#########################################################################################################
#
#  Main Section
#


my %fileStatsMap = getFileStats($dir, $changeset);

printf("Changeset,name,%s,edge,CONTAINS\n", $changeset);
for my $file (keys %fileStatsMap)
{
	my $stats = $fileStatsMap{$file};
	my ($path,$name) = ($file =~ m/\// ? $file =~ m/(.*)\/(.*)/ : ("",$file));
	my ($group, $module, $package, $relativePath) = splitModuleFilePath($dir, $path);
	my $action = $stats->{'action'};
	my $inserts = $stats->{'inserts'};
	my $deletes = $stats->{'deletes'};

	printf("File,name,%s,group,%s,module,%s,package,%s,path,%s,edge,action,%s,inserts,%s,deletes,%s,changes,%s\n", 
			$name, $group, $module, $package, $relativePath, $action, $inserts, $deletes, $inserts + $deletes);
}


#########################################################################################################
#
#  Function Section
#

sub splitModuleFilePath
{
	my ($baseDir, $path) = @_;

	my (@parts) = split('/', $path);
	my $modulePath = findModulePath($baseDir, @parts);
	if ($modulePath eq "")
	{
		return ("","","",$path);
	}
	else
	{
		my ($group, $module) = getModuleInfo($modulePath);
		my ($relativePath) = ($modulePath eq $baseDir ? "" : $modulePath =~ m/$baseDir\/(.*)/);
		my $package;
		if ($relativePath eq "")
		{
		 	$package = ($path =~ m/src\/main\/java\/(.*)/ ? $1 : "");
		}
		else
		{
		 	$package = ($path =~ m/$relativePath\/src\/main\/java\/(.*)/ ? $1 : "");
		}
		$package =~ tr/\//\./;
		#printf("\n--- [%s]\n", join(' | ', ($path, $modulePath, $relativePath, $group, $module, $package)));
		return ($group, $module, $package, $path);
	}
}

sub getModuleInfo
{
	my ($modulePath) = @_;
	my $dependencyTreeFile = "$modulePath/target/dependency-tree.txt";
	if (-f $dependencyTreeFile)
	{
		$dependencyTreeFile =~ s/ /\\ /g;
		my $results = `head -1 $dependencyTreeFile`;
		my ($group, $module) = $results =~ /digraph "(.*?):(.*?):.*/;
		return ($group,$module);
	}
	else
	{
		return ("","");
	}
}

#
# Find the Maven project directory
#
sub findModulePath
{
	my ($baseDir, @parts) = @_;

	my $path = $baseDir;
	my $moduleDir = (-f "$path/pom.xml" ? $path : "");
	for my $part (@parts)
	{
		$path .= "/$part";
		$moduleDir = (-f "$path/pom.xml" ? $path : $moduleDir);
	}
	# if ($moduleDir eq $path)
	# {
	# 	return "";
	# }
	# else
	# {
	# 	$moduleDir =~ /$path\/(.*)/;
	# 	return 	$1;
	# }
	return $moduleDir;
}

sub getFileStats
{
	my ($dir, $changeset) = @_;

	if (-d "$dir/.hg")
	{
	    getFileStatsHg($changeset);
	}
	elsif (-d "$dir/.git")
	{
	    getFileStatsGit($changeset);
	}
	else
	{
	    die "Could not find repository: $dir";
	}
}

sub getFileStatsHg
{
	my ($changeset) = @_;

	my %fileStatsMap = ();

	my @results = `cd $dir; hg status --change $changeset`;

	my $line;
	for $line (@results)
	{
	    chomp($line);
	    my ($action, $file) = $line =~ m/([ARM])? (.*)/;

	    $file =~ s/\\/\//g;
	    if ($action == "A" || $action == "R" || $action == "M")
	    {
	        my $statsResult = `cd $dir; hg log --stat -r $changeset $file |tail -2 |head -1`;
	        chomp($statsResult);
	        my ($inserts,$deletes) = $statsResult =~ m/[0-9]* files changed, ([0-9]*) insertions\(\+\), ([0-9]*) deletions\(\-\)/;
		
			my %fileStats = ('action' => $action, 'inserts' => $inserts, 'deletes' => $deletes);
			$fileStatsMap{$file} = \%fileStats;
	    }
	}

	return %fileStatsMap;
}

sub getFileStatsGit
{
	my ($changeset) = @_;

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

	return %fileStatsMap;
}