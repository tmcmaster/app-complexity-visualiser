#!/usr/bin/perl

use strict;
use lib './lib';
use Complexity::Path;
use Complexity::CSV;
use Complexity::Cypher;
use Complexity::Util;
use Complexity::Neo4j;

#########################################################################################################
#
#  Main Section
#


my ($dir) = getDirectoryPlusArgs(@ARGV);

importProject($dir);


#########################################################################################################
#
#  Function Section
#

#
# Import Project details.
#
# Child Relationships: Repository
#
sub importProject
{
	my ($projectDirectory) = @_;

	# load the Project to Repository data.
	my ($parentProjectLine, @childRepositoryLineList) = loadData('project-repositories.pl', $projectDirectory);

	# parse the Project data
	my ($parentProjectType, $parentProjectProperties, $projectToRepositoryType) = splitNodeDefinition($parentProjectLine);

	# get/create the Project
	my $parentProjectId = getOrCreateNode($parentProjectType, $parentProjectProperties);

	# process all of the Repository child records
	for my $childRepositoryLine (@childRepositoryLineList)
	{
		chomp($childRepositoryLine);

		# parse Repository data
		my ($childRepositoryType, $childRepositoryProperties, $projectToRepositoryProperties) = splitEdgeDefinition($childRepositoryLine);

		# get/create the Repository
		my $childRepositoryId = getOrCreateNode($childRepositoryType, $childRepositoryProperties);

		# create relationship between Project and Repository
		createRelationship($parentProjectId, $childRepositoryId, $projectToRepositoryType, $projectToRepositoryProperties);

		my $childRepositoryPath = $childRepositoryProperties->{'path'};
		my $childRepositoryFullPath = ($childRepositoryPath eq "" ? $projectDirectory : sprintf("%s/%s", $projectDirectory, $childRepositoryPath));
		importRepository($childRepositoryFullPath, $childRepositoryId);
	}	
}

#
# Import Repository details.
#
# Child Relationships: Changeset, Changset->Developer, Changeset->Files
#
sub importRepository
{
	my ($repositoryDirectory, $repositoryId) = @_;

	# load the Repository to Changeset data.
	my ($parentRepositoryLine, @childChangesetLineList) = loadData('repository-changesets.pl', $repositoryDirectory);

	# parse the Repository data
	my ($parentRepositoryType, $parentRepositoryProperties, $repositoryToChangesetType) = splitNodeDefinition($parentRepositoryLine);

	# get/create the Repository
	my $parentRepositoryId = (defined $repositoryId ? $repositoryId : getOrCreateNode($parentRepositoryType, $parentRepositoryProperties));

	# process all of the Changeset child records
	for my $childChangesetLine (@childChangesetLineList)
	{
		chomp($childChangesetLine);

		# parse Changeset data
		my ($childChangesetType, $childChangesetProperties, $repositoryToChangesetProperties) = splitEdgeDefinition($childChangesetLine);

		# get/create the Changeset
		my $childChangesetId = getOrCreateNode($childChangesetType, $childChangesetProperties);

		# create relationship between Repository and Changeset
		createRelationship($parentRepositoryId, $childChangesetId, $repositoryToChangesetType, $repositoryToChangesetProperties);

		my $developerName = $childChangesetProperties->{'developer'};
		my $changesetName = $childChangesetProperties->{'name'};

		importDeveloper($childChangesetId, $developerName);
		importChangesetFiles($repositoryDirectory, $childChangesetId, $changesetName);
	}		
}

#
# Import File details.
#
sub importChangesetFiles
{
	my ($repositoryDirectory, $changesetId, $changesetName) = @_;

	my ($parentChangesetLine, @childFileLineList) = loadData('changeset-file-changes.pl', $repositoryDirectory, $changesetName);

	# parse the changeset data
	my ($parentChangesetType, $parentChangesetProperties, $changesetToFileType) = splitNodeDefinition($parentChangesetLine);

	# get/create the Changeset
	my $parentChangesetId = (defined $changesetId ? $changesetId : getOrCreateNode($parentChangesetType, $parentChangesetProperties));

	# process all of the File child records
	for my $childFileLine (@childFileLineList)
	{
		chomp($childFileLine);

		# parse File data
		my ($childFileType, $childFileProperties, $changesetToFileProperties) = splitEdgeDefinition($childFileLine);

		# get/create the File
		my $childFileId = getOrCreateNode($childFileType, $childFileProperties);

		# create relationship between Changeset and File
		createRelationship($parentChangesetId, $childFileId, $changesetToFileType, $changesetToFileProperties);
	}	
}

#
# Import Developer details.
#
sub importDeveloper
{
	my ($changesetId, $developerName) = @_;

	my %developerProperties = ('name'=>$developerName);
	my $developerId = getOrCreateNode('Developer', \%developerProperties);
	my %createdByProperties = ();
	createRelationship($changesetId, $developerId, 'CREATED_BY', \%createdByProperties);
}
