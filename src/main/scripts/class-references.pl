#!/usr/bin/perl

use strict;

my $file = $ARGV[0];

unless (-f $file)
{
	die "Given file was invalid: $file";
}

$file =~ m/.*\/(.*)\.java$/;
my $sourceClass = $1;

my $packageLine = (`grep '^package .*;' $file`)[0];
$packageLine =~ /package (.*);$/;
my $sourcePackage = $1;

my @imports = (`grep 'import .*;' $file`);

printf("SourceClass,name,%s,package,%s\n",$sourceClass,$sourcePackage);
my $import;
for $import (@imports)
{
	$import =~ m/import (.*)\.(.*);/;
	my $targetPackage = $1;
	my $targetClass = $2;

	printf("TargetClass,name,%s,package,%s\n",$targetClass,$targetPackage);
}
