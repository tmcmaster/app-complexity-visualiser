#!/usr/bin/perl

use strict;

my $file = $ARGV[0];

unless (-f $file)
{
	die "Given file was invalid: $file";
}

my $filter = ($#ARGV > 0 ? $ARGV[1] : "");

$file =~ m/.*\/(.*)\.java$/;
my $sourceClass = $1;


my $packageLine = (`grep '^package .*;' $file`)[0];
$packageLine =~ /package (.*);$/;
my $sourcePackage = $1;

my @imports = (`grep 'import .*;' $file`);

printf("File,name,%s,package,%s,edge,DEPENDS_ON\n",$sourceClass,$sourcePackage);
my $import;
for $import (@imports)
{
	$import =~ m/import (.*)\.(.*);/;
	my $targetPackage = $1;
	my $targetClass = $2;

	if ($filter eq "" || $targetPackage =~ m/^$filter.*/)
	{
		printf("File,name,%s,package,%s,edge,\n",$targetClass,$targetPackage);
	}
}
