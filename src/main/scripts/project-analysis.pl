#!/usr/bin/perl

use strict;
use lib './lib';
use Complexity::Path;
use Complexity::CSV;

#########################################################################################################
#
#  Main Section
#


my ($dir) = getDirectoryPlusArgs(@ARGV);
my $project = getNameForPath($dir);

my ($projectLine, @childRepositories) = loadData('project-repositories.pl', $dir);
my ($projectPath) = (split(',', $projectLine))[2];
print "$projectLine\n";
for my $childRepository (@childRepositories)
{
	chomp($childRepository);
	printf(",%s\n", $childRepository);
	my ($repositoryPath) = (split(',', $childRepository))[6];
	my $repositoryFullPath = sprintf("%s/%s", $dir, $repositoryPath);
	my ($repositoryLine, @childModules) = loadData('project-modules.pl', $repositoryFullPath);
	for my $moduleLine (@childModules)
	{
		chomp($moduleLine);
		printf(",,%s\n", $moduleLine);
		my ($moduleName, $modulePath) = (split(',', $moduleLine))[2,4];
		my $moduleFullPath = sprintf("%s/%s", $repositoryFullPath, ($modulePath eq "" ? $moduleName : sprintf("%s/%s",$modulePath,$moduleName)));
		#print ",,,[$moduleFullPath][$modulePath:$moduleName]\n";
		my ($moduleLine, @childDependencies) = loadData('./module-dependencies.pl', $moduleFullPath);
		for my $dependencyLine (@childDependencies)
		{
			chomp($dependencyLine);
			my ($dependencyPackage) = (split(',', $dependencyLine))[4];
			if ($dependencyPackage =~ m/^au\.com\.cgu/)
			{
				printf(",,,%s\n", $dependencyLine);
			}
		}
	}
}

#########################################################################################################
#
#  Function Section
#


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