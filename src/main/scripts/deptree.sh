#!/usr/bin/perl

#find -name dependency-tree.txt |xargs cat |egrep -v '^diagram|^ }' | perl -e 'while(<>) {chomp($_);$_ =~ m/\s+"(.*):(.*):(.*):(.*):(.*)" -> "(.*):(.*):(.*):(.*):(.*)"/s; printf("%s:%s->%s:%s\n", $1,$2,$6,$7)}'

use strict;

my %nodeIds = {};

my %nodes = {};
my @edges = ();

my $nCounter = 1;
my $eCounter = 1;


for my $line (`find -name dependency-tree.txt |xargs cat`)
{
        chomp($line);
        $line =~ s/^M//g;
        my ($fromGroup,$fromNode,$toGroup,$toNode) = $line =~ m/\s+"(.*?):(.*?):.*" -> "(.*?):(.*?):.*"/s;
        #print "\n[" . $line . "]\n";
        if ($fromNode ne "")
        {
                #printf("%s:%s->%s:%s\n", $fromGroup, $fromNode, $toGroup, $toNode);
                my $fNode = getNode($fromGroup, $fromNode);
                my $tNode = getNode($toGroup, $toNode);

                my %edge = {};
                $edge{'id'} = $eCounter++;
                $edge{'source'} = $fNode;
                $edge{'target'} = $tNode;

                push(@edges, \%edge);
        }
}

my @nodeData = ();
my @edgeData = ();

my $dataTemplate = "var dependencyData = {\n\tnodes: [\n%s\n\t],\n\tedges: [\n%s\n\t]\n};";
my $nodeTemplate = "\t\t{id: %d, label: '%s', group: '%s'}";
my $edgeTemplate = "\t\t{id: %d, from: %d, to: %d}";

for my $n (keys %nodes)
{
        my $node = $nodes{$n};
        push(@nodeData, sprintf($nodeTemplate, $node->{'id'}, $node->{'name'}, $node->{'group'}));
}

my %edgeMap = map{$_->{'source'}.':'.$_->{'target'}=>$_} @edges;
for my $e (keys %edgeMap)
{
        my $edge = $edgeMap{$e};
        push(@edgeData, sprintf($edgeTemplate, $edge->{'id'}, $edge->{'source'}->{'id'}, $edge->{'target'}->{'id'}));
}

printf($dataTemplate, join(",\n", @nodeData), join(",\n", @edgeData));

sub getNode
{
        my ($group, $node) = @_;

        unless (defined $nodes{$node})
        {
                my %newNode = {};
                $newNode{'id'} = $nCounter++;
                $newNode{'name'} = $node;
                $newNode{'group'} = $group;
                $nodes{$node} = \%newNode;
        }

        return $nodes{$node};
}

