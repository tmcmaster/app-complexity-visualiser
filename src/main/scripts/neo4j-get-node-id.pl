#!/usr/bin/perl

use strict;

if ( $#ARGV < 1 ) { die "Node type is required. Properties are required." };

my $class = $ARGV[0];

my @keyValues = ($#ARGV > 0 ? @ARGV[1..$#ARGV] : ());

my @properties = ();
my $keyValue;
for $keyValue (@keyValues)
{
	my ($key,$value) = split(':', $keyValue);
	push(@properties, $key . ":\"" . $value . "\"");	
}
my $cypherTemplate = "MATCH (a:%s {%s}) return id(a)";
my $propertiesString = join(',', @properties);
#$dataString =~ s/\"/\\\"/g;
#chop($dataString);
my $cypher = sprintf($cypherTemplate, $class, $propertiesString);
#print $cypher . "\n";

my $result = `./neo4j-cypher.pl '$cypher'`;
#print $result . "\n";

if ($result =~ m/\s+"data" : \[ \]/sm)
{
	die "There was no node found.";
}

my @count = split(',', $result);
#print "COUNT: [" . $#count . "]\n";

if ($#count == 1)
{
	$result =~ m/\s+"data" : \[ \[ ([0-9]*) \] \]/sm;
	print "$1\n";
}
else
{
	die "There was more than one result: $#count";
}
