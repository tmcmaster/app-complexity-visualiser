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

print "Project,name,$project,path,$dir\n";
for my $developer (`(cd $dir; hg log --template "{author}\n" |sort |uniq)`)
{
    chomp($developer);

    my $developerString = standardiseDeveloper($developer);
    unless ($developerMap{$developerString})
    {
        $developerMap{$developerString} = 1;
        printf("Developer,name,%s\n", $developerString);
    }
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
