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

my $dir;
printf("module,name,%s\n", $moduleName);
my $sourceDir = $moduleDir . '/src/main/java';
my @packageDirectories = `cd $sourceDir; find -type d -printf "%P\n"`;

for $dir (@packageDirectories)
{
	chomp($dir);
	my $dirPath = sprintf("%s/%s/%s",$moduleDir,"src/main/java", $dir);
	my $children = `cd $dirPath; ls *.java 2>/dev/null |wc -l`;
	chomp($children);
	$dir =~ tr/\//\./;
	if ($children > 0)
	{
		printf("package,name,%s\n",$dir);	
	}
}
