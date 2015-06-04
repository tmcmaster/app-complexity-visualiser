#!/usr/bin/perl

use strict;

if ( $#ARGV < 0 ) { die "Node type is required." };


my @args = ($#ARGV > 0 ? @ARGV[1..$#ARGV] : ());

my @data = ();
my $arg;
for $arg (@args)
{
	my ($key,$value) = split(':', $arg);
	push(@data, $key . ":\"" . $value . "\"");	
}
my $dataTemplate = "{%s}";
my $dataString = join(',', @data);
#$dataString =~ s/\"/\\\"/g;
#chop($dataString);
my $postData = sprintf($dataTemplate, $dataString);
print $postData . "\n";

my $cypher = "CREATE (a:Class $postData)";
$cypher =~ s/\"/\\\"/g;
print "[" . $cypher . "]";

my $result = `curl -s -H "Accept: application/json" -H "Content-type: application/json" -X POST --data-binary '{ "query" : "$cypher" }' http://localhost:7474/db/data/cypher`;
print $result;

##my $result = `curl -s -H "Accept: application/json" -H "Content-type: application/json" -X POST --data-binary '$postData' http://localhost:7474/db/data/node`;
#print $result;
