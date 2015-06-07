package Complexity::Util;


###################################################################################################################
#
#  Export Section
#


use Exporter qw(import);

our @EXPORT = qw(parseDeveloperName loadData validateScripts);


###################################################################################################################
#
#  Libraries Section
#


use lib './lib';
use Complexity::Logging;

my $LOGGER = getOrCreateLogger('lib-util');


###################################################################################################################
#
#  Function Section
#


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
        if ($developer =~ m/ /)
        {
            # not a username, uppercase the first letters of each word.
            $developer =~ s/(\w+)/\u$1/g;
        }
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

sub validateScripts
{
    for my $scriptString (@_)
    {
        my $script = (split(' ', $scriptString))[0];
        logdie("Could not find script: $script") unless (-f "$script");
    }
}

1;
