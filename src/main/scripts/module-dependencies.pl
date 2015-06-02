#!/usr/bin/perl
#
# This script relies on maven building the dependeny tree into the target directory.
#
# mvn dependency:tree
#
# <plugin>
#     <groupId>org.apache.maven.plugins</groupId>
#     <artifactId>maven-dependency-plugin</artifactId>
#     <version>2.5.1</version>
#     <configuration>
#         <outputType>dot</outputType>
#         <outputFile>target/dependency-tree.txt</outputFile>
#     </configuration>
# </plugin>
#

use strict;

my $dir;
if ($#ARGV eq -1)
{
	$dir = `pwd`;
}
else
{
	$dir = $ARGV[0];
}

if ($dir =~ m/\/$/)
{
	chop($dir);
}

unless (-d $dir)
{
	die "Given directory was invalid: $dir";
}

my $module = `basename $dir`;

my @lines = (`cat $dir/target/dependency-tree.txt`);

my $artifact;
my $group;

my $line;
for $line (@lines)
{
	chomp($line);
	#printf("[%s]\n",$line);
	if ($line =~ m/^digraph \"(.*?):(.*?):.*/)
	{
		$group = $1;
		$artifact = $2;
		printf("SourceModule,name,%s,group,%s,edge,DEPENDS_ON\n",$artifact,$group);
	}
	elsif ($line =~ m/.*\" -> \"(.*?):(.*?):.*/)
	{
		my $targetGroup = $1;
		my $targetArtifact = $2;
		printf("TargetModule,name,%s,group,%s,edge,\n",$targetArtifact, $targetGroup);
	}
}
