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

# my $junk = "Changeset | e781487838cde8fb858ef1fb2889cc470fa2f550 | Roman Bruckner | 2015-05-22 | Roman Bruckner |  (HEAD   origin/master   origin/HEAD   master)";
# $junk =~ m/Changeset \| (.*?)\s+|.*/;
# printf("%s : %s : %s : %s", $1,$2,$3,$4);
# exit(0);

my ($dir, $noHeaders) = getDirectoryPlusArgs(@ARGV);
my $repository = getNameForPath($dir);

unless ($noHeaders eq "--no-headers")
{
	printf("repository,changeset,developer,file,changes,type,module,package,class,path\n");
}

if (-d "$dir/.hg")
{
    getChangesetDataHG($dir);
}
elsif (-d "$dir/.git")
{
    getChangesetDataGit($dir);
}
else
{
    die "Could not find repository: $dir";
}


#########################################################################################################
#
#  Function Section
#


# Example changeset log:
#
# Changeset | 96ff19fe9c781a534ca487476206f2e479b8a55d | Roman Bruckner | Fri May 22 19:32:37 2015 +0200 | Roman Bruckner |
#
# 7       1       bower.json
# 3       3       demo/basic.html
# 3       3       demo/links-sticky-points.html
#
sub getChangesetDataGit
{
	my ($dir) = @_;

	my $changeset;
	my $developer;
	my $date;
	my $changes;
	my $file;
	my $type;
	my $class;
	my $package;
	my $module;
	my $path;

	open(HG_DATA, "(cd '${dir}'; git log --numstat --date=short --format=\"Changeset | %H | %an | %ad | %cn | %d\")| head -200 |");
	while(<HG_DATA>)
	{
		chomp($_);
		#print "[$_]\n";
		if($_=~m/^Changeset \| (.*?) \| (.*) \| (.*) \| (.*) \| (.*)/)
		{
			if ($changeset ne "")
			{
				printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$repository,$changeset,$developer,$file,$changes,$type,$module,$package,$class,$path);
			}
			$changeset = $1."DGDFG";
			$developer = parseDeveloperName($2);
			$date = $3;
		}
		elsif($_=~m/^([0-9]*)\s+([0-9]*)\s(.*)/)
		{
			$changes = $1 + $2;
			($file,$type,$module,$package,$class,$path) = parseFileName($dir, $3);
		}
	}
	if ($changeset ne "")
	{
		printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$repository,$changeset,$developer,$file,$changes,$type,$module,$package,$class,$path);
	}
	close(HG_DATA);	
}

sub getChangesetDataHG
{
	my ($dir) = @_;

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
}

sub parseFileName
{
	my ($baseDir, $filePath) = @_;

	my ($file,$type,$module,$package,$class,$path) = ("","","","","",sprintf("%s/%s",$baseDir,$filePath));

	#print "[$filePath]\n";
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