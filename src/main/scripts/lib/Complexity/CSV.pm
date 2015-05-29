package Complexity::CSV;

use Exporter qw(import);

our @EXPORT = qw(splitNodeDefinition splitEdgeDefinition);

sub splitNodeDefinition
{
        my ($nodeDefinition) = @_;

        my ($class, $nodePropertiesString, $edgeType) = $nodeDefinition =~ m/(.*?),(.*),edge,(.*)/;
        my $nodeProperties = convertKeyValueListToMap(split(",", $nodePropertiesString));

        return ($class, $nodeProperties, $edgeType);
}

sub splitEdgeDefinition
{
        my ($edgeDefinition) = @_;

        my ($class, $nodePropertiesString, $junk, $edgePropertiesString) = $edgeDefinition =~ m/(.*?),(.*)(,edge,)*(.*)/;
        my $nodeProperties = convertKeyValueListToMap(split(",", $nodePropertiesString));
        my $edgeProperties = convertKeyValueListToMap(split(",", $edgePropertiesString));

        return ($class, $nodeProperties, $edgeProperties);
}

sub convertKeyValueListToMap
{
	my (@keyValueList) = @_;

	my %keyValueMap = ();

	for (my $i = 0; $i < $#keyValueList; $i += 2)
	{
		my $key = $keyValueList[$i];
		my $value = $keyValueList[$i+1];
		$keyValueMap{$key} = $value;
	}

	return \%keyValueMap;
}

1;
