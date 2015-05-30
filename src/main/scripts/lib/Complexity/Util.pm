package Complexity::Util;

use Exporter qw(import);

our @EXPORT = qw(parseDeveloperName);

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

1;
