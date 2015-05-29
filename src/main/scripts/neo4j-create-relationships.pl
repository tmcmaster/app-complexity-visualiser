#!/usr/bin/perl

use strict;

use lib './lib';

use Complexity::CSV;
use Complexity::Cypher;

my $nodeDefinition;
my @edgeDefinitions = ();
if (-t STDIN)
{
	print "Input from user\n";
}
else
{
	print "Input from process\n";

	my $line;
	while ($line = <>)
	{
		chomp $line;
		unless (defined $nodeDefinition)
		{
			print "NODE[" . $line . "]\n";
			$nodeDefinition = $line;
		}
		else
		{
			print "EDGE[" . $line . "]\n";
			push(@edgeDefinitions, $line);
		}
	}
}

unless (defined $nodeDefinition)
{
	die "There was no node definition.";
}
else
{
	my ($class, $nodeProperties, $edgeType) = splitNodeDefinition($nodeDefinition);

	my %map = %{$nodeProperties};

	my $sourceId = parseId(executeCypher(cypherGetNodeId($class, $nodeProperties)));
	if ($sourceId < 0)
	{
		$sourceId = parseId(executeCypher(cypherCreateNode($class, $nodeProperties)));
	}
	printf("NodeId[%d]\n", $sourceId);


	for my $edgeDefinition (@edgeDefinitions)
	{
		my ($targetType, $nodeProperties, $edgeProperties) = splitEdgeDefinition($edgeDefinition);
		my $result = executeCypher(cypherCreateRelationship($sourceId, $edgeType, $edgeProperties, $targetType, $nodeProperties));
		printf("%s\n",$result);
	}
}


sub parseId
{
	my ($result) = @_;

	if ($result =~ m/\s+"data" : \[ \]/sm)
	{
		return -1;
	}

	$result =~ m/\s+"data" : \[ \[ ([0-9]*) \] \]/sm;
	return $1;
}
