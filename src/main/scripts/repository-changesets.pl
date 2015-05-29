#!/usr/bin/perl

use strict;

my $dir;
my $mode = "main";

if ($#ARGV > -1)
{
    $dir = $ARGV[0];
}
else
{
    $dir = `pwd`;
}

unless (-d $dir)
{
	die "Given directory was invalid: $dir";
}

my $project = `basename $dir`;
chomp($project);

my %developerMap = ();

print "Repository,name,$project,path,$dir,edge,CONTAINS\n";
for my $changeset (`(cd $dir; hg log --template "{date|shortdate}|{node|short}|{branch}|{author}\n")`)
{
    chomp($changeset);

    my ($date,$changesetId,$branch,$developer) = split('\|',$changeset);

    my $developerString = standardiseDeveloper($developer);
    printf("Changeset,name,%s,date,%s,branch,%s,developer,%s\n", $changesetId, $date, $branch, $developerString);
}

sub standardiseDeveloper
{
    my ($user) = @_;

    my @parts = ($user =~ m/.*&.*/ ? split('&', $user)
                    : ($user =~ m/.*,.*/ ? split(',',$user)
                    : ($user =~ m/ and / ? split(' and ', $user) : $user)));
    my @developers = ();
    for my $developer (@parts)
    {
        
        if ($developer =~ m/</)
        {
            $developer = (split('<', $developer))[0]; 
        }
        $developer =~ s/^\s+//;
        $developer =~ s/\s+$//;
        $developer = lc $developer;
        $developer =~ tr/\./ /;
        $developer =~ s/(\w+)/\u$1/g;
        push(@developers, $developer);
    }

    my $developerString = join(' & ', @developers);

    return $developerString;
}
