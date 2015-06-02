package Complexity::Util;

use Exporter qw(import);

our @EXPORT = qw(parseDeveloperName loadData);

sub parseDeveloperName
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

1;
