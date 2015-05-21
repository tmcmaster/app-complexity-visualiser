#!/usr/bin/perl

use strict;

my @lines = (`cat cudos-class-dependency-map.json`);
my $line;
my %nodes = {};
my $id;
my $node;
my $source;
my $target;
my %nodes = {};
my %nodeCounter = {};
my %sourceCounter = {};
my %targetCounter = {};

for my $line (@lines)
{
    if ($line =~ m/\s+"id":(.*?),\n/)
    {
        $id=$1;
    }
    elsif ($line =~ m/\s+"caption": "(.*?)"\n/)
    {
        $node = $1;
        $nodes{$id}=$node;
    }
    elsif ($line =~ m/\s+"source": (.*?),\n/)
    {
        $source = $nodes{$1};
    }
    elsif ($line =~ m/\s+"target": (.*?),\n/)
    {
        $target = $nodes{$1};
        if ($source=~m/^au.com\.cgu/ && $target=~m/^au\.com\.cgu/)
        {
            unless (defined $nodeCounter{$source})
            {
                $nodeCounter{$source} = 0;
                $sourceCounter{$source} = 0;
                $targetCounter{$target} = 0;
            }
            #print "$source->$target\n";
            $nodeCounter{$source}++;
            $nodeCounter{$target}++;
            $sourceCounter{$source}++;
            $targetCounter{$target}++;
        }
    }
}


print "Class Name,Is a Source,Is a Target\n";

for $node (keys %nodeCounter)
{
    if ($sourceCounter{$node} > 10 || $targetCounter{$node} > 10)
    {
        printf("%s,%d,%d\n", $node, $sourceCounter{$node}, $targetCounter{$node});
    }
}
