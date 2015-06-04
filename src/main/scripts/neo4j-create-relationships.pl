#!/usr/bin/perl

use strict;

use lib './lib';

use Complexity::CSV;
use Complexity::Cypher;

my ($joinName, $joinType, $joinLabel) = ($#ARGV > -1 ? split(':', $ARGV[0]) : ());

my $nodeDefinition;
my @edgeDefinitions = ();
# if (-t STDIN)
# {
# 	print "Input from user\n";
# 	# work in progress
# }
# else
# {
	print "Input from process\n";

	my $line;
	while ($line = <STDIN>)
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
# }

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
	printf("SourceId[%d]\n", $sourceId);


	for my $edgeDefinition (@edgeDefinitions)
	{
		my ($targetType, $nodeProperties, $edgeProperties) = splitEdgeDefinition($edgeDefinition);
		my $result = executeCypher(cypherCreateRelationship($sourceId, $edgeType, $edgeProperties, $targetType, $nodeProperties));

		my ($edgeId, $targetId) = parseMultipleIds($result);
		printf("EdgeId[%d] : TargetId[%d]\n", $edgeId, $targetId);

		if (defined $joinName)
		{
			my $joinValue = $nodeProperties->{$joinName};
			printf("%s[%d](%s) -> %s[%s]\n", $targetType, $targetId, $joinName, $joinType, $joinValue);
			my %joinProperties = ();
			my %targetProperties = ();
			$targetProperties{'name'} = $joinValue;

			my $joinId = getOrCreateNode($joinType, \%targetProperties);
			createRelationship($targetId, $joinId, $edgeType, \%joinProperties);
		}
	}
}

sub createRelationship
{
	my ($sourceId, $targetId, $edgeType, $edgeProperties) = @_;

	my $edgePropertiesString = convertKeyValueMapToPropertiesString($edgeProperties);

	my $cypher = sprintf("MATCH (c),(d) WHERE id(c) = %d and id(d) = %d CREATE UNIQUE (c)-[:%s {%s}]->(d)",
	 					$sourceId, $targetId, $edgeType, $edgePropertiesString);

	executeCypher($cypher);
}

sub getOrCreateNode
{
	my ($class, $nodeProperties) = @_;

	my $nodeId = parseId(executeCypher(cypherGetNodeId($class, $nodeProperties)));
	if ($nodeId < 0)
	{
		$nodeId = parseId(executeCypher(cypherCreateNode($class, $nodeProperties)));
	}

	return $nodeId;
}

sub parseMultipleIds
{
	my ($result) = @_;

	my ($idList) = $result =~ m/\s+"data" : \[ \[ (.*) \] \]/sm;
	return split(', ', $idList);
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
