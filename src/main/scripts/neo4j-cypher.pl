#!/usr/bin/perl

use strict;

if ( $#ARGV < 0 ) { die "Cypher was not supplied." };

my $cypherTemplate = $ARGV[0];
$cypherTemplate =~ s/\"/\\\"/g;
#print $cypherTemplate;

my @args = ($#ARGV > 0 ? @ARGV[1..$#ARGV+1] : ());

my $cypher = sprintf($cypherTemplate, @args);
#print $cypher . "\n";

#curl -H "Accept: application/json" -H "Content-type: application/json" -X POST --data-binary '{ "query" : "MATCH (a:Class {name:\"ClassB\"}) return a", "params" : { } }' http://localhost:7474/db/data/cypher
my $result = `curl -s -H "Accept: application/json" -H "Content-type: application/json" -X POST --data-binary '{ "query" : "$cypher" }' http://localhost:7474/db/data/cypher`;
print $result;
