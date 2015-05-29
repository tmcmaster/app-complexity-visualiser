#!/usr/bin/perl

use strict;

my $dir;
if ($#ARGV eq -1)
{
	$dir = `pwd`;
}
else
{
	$dir = $ARGV[0];
}

if ($dir =~ m/\/$/)
{
	chop($dir);
}

unless (-d $dir)
{
	die "Given directory was invalid: $dir";
}

my @hgdirs = (`find $dir -name .hg`);

my $project = `basename $dir`;
chomp($project);

printf("Project,name:%s,path,%s\n",$project,$dir);
my $line;
for $line (@hgdirs)
{
	chomp($line);
	$line =~ qr/$dir\/(.*)\/.hg/;
	my $projectPath = $1;
	my $path = '';
	my $module = $projectPath;
	if ($projectPath =~ m/\//)
	{
		($path,$module) = $projectPath =~ m/(.*)\/(.*)/;
	}
	printf("Repository,name,%s,path,%s\n",$module,$path);
}
