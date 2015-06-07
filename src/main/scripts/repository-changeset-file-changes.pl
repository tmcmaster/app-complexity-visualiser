#!/usr/bin/perl
#
#  Inspired by: hg log --stat | perl -e 'my $s,$f,$d,$c;while(<>){chomp($_);if($_=~m/^changeset:.*:(.*)/){$s=$1}elsif($_=~m/^user:\s+(.*)/){$d=$1}elsif($_=~m/\s+(.*?)\s+\|\s+([0-9]*)\s[+-]*/){$f=$1;$c=$2;printf("%s|%s|%s|%s\n",$s,$d,$f,$c);}}'
#

use strict;
use lib './lib';
use Complexity::Path;
use Complexity::Util;

#########################################################################################################
#
#  Main Section
#


my ($dir, $noHeaders) = getDirectoryPlusArgs(@ARGV);
my $repository = getNameForPath($dir);

my $changeset;
my $developer;
my $changeset;
my $changes;
my $file;
my $type;
my $class;
my $package;
my $module;
my $path;

unless ($noHeaders eq "--no-headers")
{
	printf("repository,changeset,developer,file,changes,type,module,package,class,path\n");
}

open(HG_DATA, "(cd '${dir}'; hg log --stat) |");
while(<HG_DATA>)
{
	chomp($_);
	if($_=~m/^changeset:.*:(.*)/)
	{
		$changeset=$1
	}
	elsif($_=~m/^user:\s+(.*)/)
	{
		$developer = parseDeveloperName($1)
	}
	elsif($_=~m/\s+(.*?)\s+\|\s+([0-9]*?)\s.*/)
	{
		($file,$type,$module,$package,$class,$path) = parseFileName($dir, $1);

		$changes=$2;
		printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$repository,$changeset,$developer,$file,$changes,$type,$module,$package,$class,$path);
	}
}
close(HG_DATA);


#########################################################################################################
#
#  Function Section
#


sub parseFileName
{
	my ($baseDir, $filePath) = @_;

	my ($file,$type,$module,$package,$class,$path) = ("","","","","",sprintf("%s/%s",$baseDir,$filePath));

	print "[$filePath]\n";
	if ($filePath =~ m/(.*)[\/]*src\/main\/java\/(.*)\/(.*?)\.java/)
	{
		$type = "Class";
		$module = $1;
		$package = $2;
		$class = $3;
		$file = sprintf("%s.java", $class);
	}
	elsif ($filePath =~ m/(.*?)\/src\/main\/resource\/(.*)\/(.*?)/)
	{
		$type = "Resource";
		$module = $1;
		$package = $2;
		$file = $3;
	}
	elsif ($filePath =~ m/(.*?)\/src\/test\/java\/(.*)\/(.*?)\.java/)
	{
		$type="TestClass";
		$module = $1;
		$package = $2;
		$class = $3;
		$file = sprintf("%s.java", $class);
	}
	elsif ($filePath =~ m/(.*)\/pom.xml/)
	{
		$type = "Config";
		$module = $1;
		$file = "pom.xml";
	}
	elsif ($filePath =~ m/(^\.[a-z]*)$/)
	{
		$type = "Config";
		$file = $1;
	}
	elsif ($filePath =~ m/(.*)\/(.*)/)
	{
		$type = "File";
		$file = $2;
	}
	else
	{
		$type = "File";
		$file = $filePath;
	}

	return ($file,$type,$module,$package,$class,$path);
}