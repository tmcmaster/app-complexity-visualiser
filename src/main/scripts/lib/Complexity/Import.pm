package Complexity::Import;


###################################################################################################################
#
#  Import Section
#


use strict;

use threads;
use Thread;
use Thread::Queue;
use Getopt::Long;
use Pod::Usage;
use Exporter qw(import);

use lib './lib';
use Complexity::Logger;
use Complexity::Util;


###################################################################################################################
#
#  Export Section
#


use Exporter qw(import);
our @EXPORT = qw(generateCypherImportFiles);


###################################################################################################################
#
#  Static Section
#


my $TEMPLATE_USING         = "\nUSING PERIODIC COMMIT 1000";
my $TEMPLATE_LOAD          = "\nLOAD CSV WITH HEADERS FROM \"%s/%s.csv\" AS line";
my $TEMPLATE_CREATE        = "\nCREATE (%s:%s {%s})";
my $TEMPLATE_MATCH         = "\nMATCH (%s:%s {%s})";
my $TEMPLATE_MERGE         = "\nMERGE (%s:%s {%s})";
#my $TEMPLATE_RELATIONSHIP  = "\nCREATE (%s {%s})-[%s]->(%s {%s})";
my $TEMPLATE_RELATIONSHIP  = "\nCREATE (%s)-[%s]->(%s)";

my $LOGGER = new Logger('complexity-import','ERROR',0);


###################################################################################################################
#
#  Function Section
#


#
#  Generate the Cypher import into the database scripts (CSQ)
#
sub generateCypherImportFiles
{
	my ($typeMap, $tmpDir, $type, $parentType) = @_;
	
	my $outputDirURI = generateOutputDirURI($tmpDir);
	my $filePath = sprintf("%s/import.cql", $tmpDir);

	my $fh;
	open($fh, ">", $filePath);

	print $fh "\n//\n// clearing the database\n//\n\n";
	print $fh "MATCH (n)-[r]-(m) delete r,n,m;\n\n";

	writeTypeImportCypherToFileHandleRecursive($fh, $outputDirURI, $typeMap, $type, $parentType);
	close($fh);
}

#
#  Recursively walk the given TypeMap, and write Cypher commands to a given file handle
#
sub writeTypeImportCypherToFileHandleRecursive
{
	my ($fh, $outputDirURI, $typeMap, $type, $parentType) = @_;

	my $columnDef = $typeMap->{$type}->{'columns'};

	writeTypeImportCypherToFileHandle($fh, $outputDirURI, $typeMap, $type, $columnDef, $parentType);

	my $children = $typeMap->{$type}->{'children'};
	for my $child (@{$children})
	{
		my $childType = $child=>{'type'};
		writeTypeImportCypherToFileHandleRecursive($fh, $outputDirURI, $typeMap, $childType->{'type'}, $type);
	}
}

# USING PERIODIC COMMIT 1000
# LOAD CSV WITH HEADERS FROM "file:c:/Users/Tim/Workspace/Neo4j/scratch/changeset.csv" AS line
# MATCH (r:Repository {name:line.repository})
# MERGE (d:Developer {name:line.developer})
# MERGE (f:File {path:line.path,name:line.file,changes:line.changes})
# CREATE (c:Changeset {name:line.name,repository:line.repository,developer:line.developer,file:line.file,changes:line.changes,path:line.path})
# CREATE (r)-[:CONTAINS]->(c)
# CREATE (c)-[:BELONGS_TO]->(r)
# CREATE (c)-[:CREATED_BY]->(d)
# CREATE (d)-[:CREATED]->(c)
# CREATE (c)-[:CHANGED]->(f)
# CREATE (f)-[:CHANGED_BY]->(c);
sub writeTypeImportCypherToFileHandle
{
	my ($fh, $outputDirURI, $typeMap, $type, $columnDef, $parentType) = @_;

	# get row details
	my $rowAlias = $typeMap->{$type}->{'alias'};
	my $rowClass = ($type =~ m/-/ ? ucfirst((split('-', $type))[1]) : ucfirst($type));
	my $rowKeys = $columnDef->{'keys'};
	my $rowProps = $columnDef->{'props'};
	my $rowKeyString = createPropropertiesString('keys', @{$rowKeys});
	my $rowPropsString = createPropropertiesString('row', @{$rowKeys}, @{$rowProps});
	
	print $fh "\n//\n// importing $type\n//\n\n";

	# Load the data
	printf $fh $TEMPLATE_USING;
	printf $fh $TEMPLATE_LOAD, $outputDirURI, $type;

	# if there is a patent
	if (defined $parentType)
	{
		my $parentAlias = $typeMap->{$parentType}->{'alias'};
		my $parentClass = ucfirst($parentType);
		my $parentKeys = $columnDef->{'parent'}->{'keys'};
		my $parentPropsString = createPropropertiesString('parent', @{$parentKeys});

		# match the parent
		printf $fh $TEMPLATE_MATCH, $parentAlias, $parentClass, $parentPropsString;
	}

	# if there are children
	if (defined $columnDef->{'children'})
	{

		# for each of the children
		for my $child (@{$columnDef->{'children'}})
		{
			my $childType = $child->{'type'};
			my $childClass = ucfirst($childType);
			my $childAlias = $typeMap->{$childType}->{'alias'};
			my $childkeys = $child->{'keys'};
			my $childProps = $child->{'props'};
			my $childPropsString = createPropropertiesString('child', @{$childkeys}, @{$childProps});

			# merge the child
			printf $fh $TEMPLATE_MERGE, $childAlias, $childClass, $childPropsString;
		}
	}

	printf $fh $TEMPLATE_MERGE, $rowAlias, $rowClass, $rowPropsString;

	# if there is a parent
	if (defined $parentType)
	{
		my $parentAlias = $typeMap->{$parentType}->{'alias'};
		my $parentKeys = $columnDef->{'parent'}->{'keys'};
		my $parentToRow = $columnDef->{'parent'}->{'relationship'}->{'parent-row'};			
		my $rowToParent = $columnDef->{'parent'}->{'relationship'}->{'row-parent'};			
		my $parentKeyString = createPropropertiesString('keys', @{$parentKeys});

		# add the parent / row realtionships
		_createRelationship($fh, $parentAlias, $parentKeyString, $parentToRow, $rowAlias, $rowKeyString);
		_createRelationship($fh, $rowAlias, $rowKeyString, $rowToParent, $parentAlias, $parentKeyString);
	}

	# if there are children
	if (defined $columnDef->{'children'})
	{
		# for each child
		for my $child (@{$columnDef->{'children'}})
		{
			my $childType = $child->{'type'};
			my $childClass = ucfirst($childType);
			my $childAlias = $typeMap->{$childType}->{'alias'};
			my $childKeys = $child->{'keys'};
			my $relationship = $child->{'relationships'};
			my $rowToChild = $relationship->{'row-child'};
			my $childToRow = $relationship->{'child-row'};
			my $childKeyString = createPropropertiesString('keys', @{$childKeys});

			# add the row / child realtionships
			_createRelationship($fh, $rowAlias, $rowKeyString, $rowToChild, $childAlias, $childKeyString);
			_createRelationship($fh, $childAlias, $childKeyString, $childToRow, $rowAlias, $rowKeyString);
		}
	}

	print $fh ";\n";
}

sub _createRelationship
{
	my ($fh, $fromAlias, $fromKeyString, $relationship, $toAlias, $toKeyString) = @_;

	unless (defined $fromAlias && defined $toAlias)
	{
		$LOGGER->warn("Both FromAlias(%s) and ToAlias(%s) need to be defined to create a relationship.", $fromAlias, $toAlias);
		return;
	}

	my $relationshipString = (defined $relationship ? ":".$relationship : "");
	#printf $fh $TEMPLATE_RELATIONSHIP, $fromAlias, $fromKeyString, $relationshipString, $toAlias, $toKeyString;
	printf $fh $TEMPLATE_RELATIONSHIP, $fromAlias, $relationshipString, $toAlias;
}

#
#  Create the properties string, comma separated list of colin separated key/value pairs.
#
sub createPropropertiesString
{
	my ($mode, @props) = @_;

	my @propList = ();
	for my $prop (@props)
	{
		my ($key,$value) = split(':', $prop);
		unless (defined $value)
		{
			$value = $key;
		}
		$key = $value if ($mode eq 'row');
		push(@propList, "$key:coalesce(line.$value, '')") unless ($prop eq "");
	}
	return join(',', @propList);	
}

#
#  Generate a URI from a given directory path.
#
sub generateOutputDirURI
{
	my ($outputDir) = @_;

	if ($outputDir =~ m/\/cygdrive\/([A-z])\/(.*)/)
	{
		return sprintf("file:%s:/%s",$1,$2);
	}
	else
	{
		return sprintf("file:%s",$outputDir);
	}
}

1;