#!/usr/bin/perl

use strict;

use lib './lib';
use Complexity::Logging;
use Log::Log4perl::Level;
use Getopt::Long;


###################################################################################################################
#
#  Options Section
#


my $headers = 0;
my $name;
my $owner;
my $path;
my $list;
my $all;
my $help;
my $man;

GetOptions ("headers"          => \$headers,
            "name=s"           => \$name,
            "owner=s"          => \$owner,
            "path=s"           => \$path,
            "list=s"		   => \$list,
            "all"              => \$all,
            "help|?"           => \$help,
            "man"              => \$man)
  			or die("Error in command line arguments\n");

pod2usage(1) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $man;


###################################################################################################################
#
#  Static Section
#


my $LOGGER = getOrCreateLogger('csvgen-project', $DEBUG);

my %projectMap = (
	"Libraries" => "Tim McMaster,/cygdrive/c/Users/Tim/Workspace/Mercurial/Libraries",
	"Apps" => "Tim McMaster,/cygdrive/c/Users/Tim/Workspace/Mercurial/Apps",
	"Alchemy" => "GraphAlchemist,/cygdrive/c/Users/Tim/Workspace/Clone/Alchemy",
	"betterFORM" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/betterFORM",
	"CodeMirror" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/CodeMirror",
	"eXist" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/eXist",
	"javaparser" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/javaparser",
	"Jersey" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/Jersey",
	"Jetty" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/Jetty",
	"JointJS" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/JointJS",
	"XMLEditor" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/jquery.xmleditor",
	"Neo4j" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/Neo4j",
	"XULRunner-Example" => "TBD,/cygdrive/c/Users/Tim/Workspace/Clone/XULRunner-Examples",
	"GetStuffDone" => "TBD,/cygdrive/c/Users/Tim/Workspace/Mercurial/Apps/get-stuff-done"
);


###################################################################################################################
#
#  Validation Section
#


unless (-f "./csvgen-create-all.pl") { die "This script needs to be run from the script directory."};


die "If --all is selected, --name, --path, --owner and --list are not required." if ($all == 1 && (defined $name || defined $owner || defined $path || defined $list));
die "If --path or --owner is set, all -name, -owner and --path are required." if ((defined $owner || defined $path)  && (! defined $name || !defined $owner || ! defined $path));
die "At least one of --name, --all or --list is required." if (!defined $name && !defined $list && !defined $all);
die "Could not find the path directory: '$path'" if (defined $path && ! -d "$path");

###################################################################################################################
#
#  Main Section
#


$LOGGER->debug('Creating Project list. Looking for projects.');

if ($headers == 1)
{
	print "name,owner,path\n";
}

if (defined $name && defined $owner && defined $path)
{
	printProject($name,$owner,$path);
}
elsif (defined $name)
{
	my $projectLine = $projectMap{$name};
	die "There is not a registered project called: $name" unless defined $projectLine;
	my ($owner,$path) = split(',',$projectLine);
	printProject($name,$owner,$path);
}
elsif (defined $list)
{
	for my $name (split(',', $list))
	{
		my $projectLine = $projectMap{$name};
		die "There is not a registered project called: $name" unless defined $projectLine;
		my ($owner,$path) = split(',',$projectLine);
		printProject($name,$owner,$path);
	}
}
elsif (defined $all)
{
	for my $name (keys %projectMap)
	{
		my $projectLine = $projectMap{$name};
		die "There is not a registered project called: $name" unless defined $projectLine;
		my ($owner, $path) = split(',',$projectLine);
		printProject($name,$owner,$path);
	}
}
else
{
	die "There was nothing to do";
}

sub printProject
{
	my ($name,$own,$path) = @_;
	die "Could not find path directory. Name($name), Path($path)." if (!-d "$path");
	print join(',', @_)."\n";
}


###################################################################################################################
#
#  Manual Section
#


#-----------------------------------------------------------------
#----------------  Documentation / Usage / Help ------------------
=head1 NAME

csvgen-create-all.pl - Project analiser.

=head1 SYNOPSIS

csvgen-create-all.pl [options]

=head1 OPTIONS

=over 8

=item B<--help>  

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--type>  

The type of entity to analise.

=item B<--name>  

The name of the entity to be analised.

=item B<--path>  

The path to the element to be analised.

=item B<--log-level>  

The log level to be used.

=item B<--dry-run>  

Don't do anything, just pring out the option values.

=item B<--override>  

Override the relationship CSV files.

=back

=head1 DESCRIPTION

Get a list of project details.

=cut