#!/usr/bin/perl

use strict;
use lib './lib';
use Complexity::Path;

#########################################################################################################
#
#  Main Section
#


my ($dir) = getDirectoryPlusArgs(@ARGV);
my $repository = getNameForPath($dir);

my @pomFiles = (`find $dir -name pom.xml |egrep -v '\/build\/|\/target\/|\/.metadata\/'`);

printf("Repository,name,%s,path,%s,edge,CONTAINS\n",$repository,$dir);
my $line;
for $line (@pomFiles)
{
	chomp($line);
	$line =~ qr/$dir\/(.*)\/pom.xml/;
	my $relativePath = $1;
	if (-f "$dir/$relativePath/target/dependency-tree.txt")
	{
		my $moduleLine = `head -1 $dir/$relativePath/target/dependency-tree.txt`;
		chomp($moduleLine);
		my ($group,$name) = $moduleLine =~ m/^digraph \"(.*?):(.*?):.*/;
		printf("Module,name,%s,module,%s,path,%s,edge,\n",$name,$group,$relativePath);
	}
}
