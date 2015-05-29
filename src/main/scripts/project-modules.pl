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

my @pomFiles = (`find $dir -name pom.xml |egrep -v '\/build\/|\/target\/'`);

printf("project,name:%s\n",$dir);
my $line;
for $line (@pomFiles)
{
	chomp($line);
	$line =~ qr/$dir\/(.*)\/pom.xml/;
	my $projectPath = $1;
	my $path = '';
	my $module = $projectPath;
	if ($projectPath =~ m/\//)
	{
		($path,$module) = $projectPath =~ m/(.*)\/(.*)/;
	}
	printf("module,name,%s,path,%s\n",$module,$path);
}
