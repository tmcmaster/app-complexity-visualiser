#!/usr/bin/perl

use strict;
use lib './lib';
use Complexity::Path;

#########################################################################################################
#
#  Main Section
#


my ($dir) = getDirectoryPlusArgs(@ARGV);
my $project = getNameForPath($dir);

printf("Project,name:%s,path,%s\n", $project, $dir);
for my $path (`find $dir -name '.git' -o -name '.hg'`)
{
	chomp($path);

	my ($baseDir, $relativePathDir, $name, $file) = splitPath($dir, $path);
	my $type = ($file eq ".hg" ? "Mercurial" : ($file eq ".git" ? "Git" : ""));
	printf("Repository,name,%s,type,%s,path,%s\n", $name, $type, $relativePathDir);
}
