#!/usr/bin/perl

use strict;

my $data = `cat ../resources/git-log.txt`;

#print $data;

$\=undef;
my @records = ($data =~ m/(commit.*Date)/ms);

for my $record (@records)
{
	print "[" . $record . "]";
}
