package Complexity::Cypher;

use strict;

use Exporter qw(import);

our @EXPORT = qw(cypherGetNodeId cypherCreateNode cypherCreateRelationship executeCypher convertKeyValueMapToPropertiesString);

sub cypherGetNodeId
{
    my ($class, $nodeProperties, @includeList) = @_;

	my $propertiesString = convertKeyValueMapToPropertiesString($nodeProperties, @includeList);
	my $cypher = sprintf("MATCH (n:%s {%s}) RETURN id(n)", $class, $propertiesString);

    return ($cypher);
}

sub cypherCreateNode
{
    my ($class, $nodeProperties) = @_;

	my $propertiesString = convertKeyValueMapToPropertiesString($nodeProperties);
	my $cypher = sprintf("CREATE (n:%s {%s}) RETURN id(n)", $class, $propertiesString);

    return ($cypher);
}

sub cypherCreateRelationship
{
	my ($sourceId, $relationshipType, $relationshipProperties, $targetType, $targetProperties) = @_;

	my $relationshipPropertiesString = convertKeyValueMapToPropertiesString($relationshipProperties);
	my $targetPropertiesString = convertKeyValueMapToPropertiesString($targetProperties);

	my $cypher = sprintf("MATCH (s) WHERE id(s) = %d CREATE UNIQUE (s)-[r:%s {%s}]->(t:%s {%s}) RETURN id(r),id(t)", $sourceId, $relationshipType, $relationshipPropertiesString, $targetType, $targetPropertiesString);

    return ($cypher);
}

sub executeCypher
{
	my ($cypher) = @_;

	$cypher =~ s/\"/\\"/g;
	print "$cypher\n"; 
	my $result = `curl -s -H "Accept: application/json" -H "Content-type: application/json" -X POST --data-binary '{ "query" : "$cypher" }' http://localhost:7474/db/data/cypher`;
	print "$result\n";
	
	return $result;
}

sub convertKeyValueMapToPropertiesString
{
	my ($nodeProperties, @includeList) = @_;

	my @nodePropertiesList = ();
	for my $key ($#includeList > 0 ? @includeList : keys %{$nodeProperties})
	{
		my $value = $nodeProperties->{$key};
		push(@nodePropertiesList, sprintf("%s:\"%s\"", $key, $value));
	}

	return join(",", @nodePropertiesList);
}

1;
