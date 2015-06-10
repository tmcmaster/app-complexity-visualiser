package Logger;

###################################################################################################################
#
#  Import Section
#


use strict;

use Log::Log4perl;
use Log::Log4perl::Layout;
use Log::Log4perl::Level;
use threads;


###################################################################################################################
#
#  Static Section
#


my $APPENDER;

my %threadIndent: shared = (0=>"");
my $logIndent : shared;

###################################################################################################################
#
#  Function Section
#


#
# Constructor
#
sub new
{
    my $class = shift;
    my $loggerName = shift;
    my $loggerLevel = shift;
    $logIndent = shift;

 	# create the logger
	my $logger = Log::Log4perl->get_logger($loggerName);

	# set the log level
	my $logLevel = ($loggerLevel == 'DEBUG' ? $DEBUG
					: ($loggerLevel == 'INFO' ? $INFO
					: ($loggerLevel == 'WARN' ? $WARN
					: ($loggerLevel == 'ERROR' ? $ERROR : $WARN))));

	#$logLevel = (defined $logLevel ? $logLevel : $INFO);
	$logger->level($logLevel);

	unless (defined $APPENDER)
	{
		# Define a layout
		#my $layout = Log::Log4perl::Layout::PatternLayout->new("[%-5p] %d  - %F{1}(%L) %m%n");
		my $layout = Log::Log4perl::Layout::PatternLayout->new("[%-5p] %d  - %m%n");

		# Define a file appender
		my $file_appender = Log::Log4perl::Appender->new(
		                      "Log::Log4perl::Appender::File",
		                      name      => "filelog",
		                      filename  => sprintf("/tmp/%s.log", $loggerName));

		$file_appender->layout($layout);
		$APPENDER = $file_appender;
	}

	# set the file appender
	$logger->add_appender($APPENDER);

 	my $self = {
    	_logger => $logger
    };
 
    bless $self, $class;

   	$self->info("Created logger: Name(%s), Level(%s)", $loggerName, $loggerLevel);

    return $self;
}

# log a debug level message
sub debug {
    my ($self, $message, @args) = @_;
    $self->{_logger}->debug(slogf($message, @args));
}

# log a DEBUG level message, stamped with the thread ID
sub info {
    my ($self, $message, @args) = @_;
    $self->{_logger}->info(slogf($message, @args));
}

# log a WARN level message, stamped with the thread ID
sub warn {
    my ($self, $message, @args) = @_;
    $self->{_logger}->warn(slogf($message, @args));
}

# log a ERROR level message, stamped with the thread ID
sub error {
    my ($self, $message, @args) = @_;
    $self->{_logger}->error(slogf($message, @args));
}

sub slogf
{
	my ($message, @args) = @_;
	return sprintf("%s[%3d] ".$message, getIndent(), threads->tid(), @args);
}

sub getIndent
{
	my ($self) = @_;

	return "" unless (defined $logIndent && $logIndent == 1);
	my $threadId = threads->tid();
	my $indent = $threadIndent{$threadId};
	#print "Looking up indent for thread $threadId [$indent]\n";
	return (defined $indent ? $indent : "");
}

sub setThreadIndent
{
	my ($self, $parentId, $childId) = @_;

	#printf("Added thread indent: %d => %d\n", $parentId, $childId);
	$threadIndent{$childId} = $threadIndent{$parentId}."  ";
}

1;