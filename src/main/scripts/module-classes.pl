#!/usr/bin/perl

use strict;
#use GetOpts::Long;

my $dir;
my $mode = "main";

if ($#ARGV > -1)
{
	if ($ARGV[0] eq "--test-classes")
	{
		$mode = "test";
		if ($#ARGV > 0)
		{
			$dir = $ARGV[1];
		}
		else
		{
			$dir = `pwd`;
		}
	}
	else
	{
		$dir = $ARGV[0];
	}
}

unless (-d $dir)
{
	die "Given directory was invalid: $dir";
}

my @pomFiles = `find $dir -name pom.xml`;
if ($#pomFiles+1 eq 0)
{
	die "Could not find a module within directory: " + $dir;
}
my $moduleDir = `dirname $pomFiles[0]`;
my $moduleName = `basename $moduleDir`;

chomp($moduleDir);
chomp($moduleName);

printf("Module,name,%s,edge,CONTAINS\n", $moduleName);
my $sourceDir = sprintf("%s/src/%s/java", $moduleDir, $mode);
my @filePaths = `cd $sourceDir; find -type f -name '*.java' -printf "%P\n"`;

my $filePath;
for $filePath (@filePaths)
{
	chomp($filePath);
	my ($package, $class) = $filePath =~ m/(.*)\/(.*?).java/;
	$package =~ tr/\//\./;
	printf("Class,name,%s,package,%s\n",$class,$package);	
}
