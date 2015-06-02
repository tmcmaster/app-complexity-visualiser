#!/usr/bin/perl

use strict;

use lib './lib';
use JSON::Parse 'parse_json';

my $jsonString = "";
while (<STDIN>)
{
	$jsonString .= $_;
}

my $result = parse_json($jsonString);

if (defined $result->{'stackTrace'})
{
	die "Neo4j Cypher ERROR: $jsonString";
}

my $columns = $result->{'columns'};
my $data = $result->{'data'};

print join(',', @{$columns}) . "\n";

for my $row (@{$data})
{
	print join(',', @{$row}) . "\n";
}
