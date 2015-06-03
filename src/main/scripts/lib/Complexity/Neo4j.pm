package Complexity::Neo4j;

use Exporter qw(import);

use Complexity::Cypher;
use JSON::Parse 'parse_json';

our @EXPORT = qw(createRelationship getOrCreateNode parseMultipleIds parseId loadData parseResults);

sub createRelationship
{
	my ($sourceId, $targetId, $edgeType, $edgeProperties) = @_;

	my $edgePropertiesString = convertKeyValueMapToPropertiesString($edgeProperties);

	my $cypher = sprintf("MATCH (c),(d) WHERE id(c) = %d and id(d) = %d CREATE UNIQUE (c)-[:%s {%s}]->(d)",
	 					$sourceId, $targetId, $edgeType, $edgePropertiesString);

	#print "\n[$cypher]\n";

	executeCypher($cypher);
}

sub parseResults
{
	my ($neoResult) = @_;

	my $result = parse_json($neoResult);
	my $cols = $result->{'columns'};
	my $data = $result->{'data'};
	my @columns = @{$cols};
	my @results = ();
	for my $row (@{$data})
	{
		my %rowData = ();
		for my $i (0..$#columns)
		{
			my $key = $columns[$i];
			my $value = @{$row}[$i];
			$rowData{$key} = $value;
		}
		push(@results, \%rowData);
	}

	return (\@columns, \@results);
}


#
#  TODO: This can be done with MERGE ??
#
sub getOrCreateNode
{
	my ($class, $nodeProperties, @includeList) = @_;

	my $nodeId = parseId(executeCypher(cypherGetNodeId($class, $nodeProperties, @includeList)));
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

sub loadData
{
	my ($script, @args) = @_;

	my $argsString = join(' ', @args);

	my $command = sprintf("./%s %s", $script, $argsString);
	#print "[$command]\n";
	my $parentLine;
	my @childLines = ();
	for my $line (`$command`)
	{
		chomp($line);
		unless (defined $parentLine)
		{
			$parentLine = $line;
		}
		else
		{
			push(@childLines, $line);
		}
	}
	return ($parentLine, @childLines);
}

1;
