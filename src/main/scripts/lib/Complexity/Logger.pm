package Logger;

use strict;

use Log::Log4perl;
use Log::Log4perl::Layout;
use Log::Log4perl::Level;
use threads;

my %levels = (
	'DEBUG' => $DEBUG,
	'INFO' => $INFO.
	'ERROR' => $ERROR
);

sub new
{
    my $class = shift;
    my $loggerName = shift;
    my $loggerLevel = shift;

 	# create the logger
	my $logger = Log::Log4perl->get_logger($loggerName);

	# set the log level
	my $logLevel = $levels{(defined $loggerLevel ? $loggerLevel : 'INFO')};
	$loggerLevel = (defined $loggerLevel ? $loggerLevel : $INFO);
	$logger->level($DEBUG);

	# Define a layout
	#my $layout = Log::Log4perl::Layout::PatternLayout->new("[%-5p] %d  - %F{1}(%L) %m%n");
	my $layout = Log::Log4perl::Layout::PatternLayout->new("[%-5p] %d  - %m%n");

	# Define a file appender
	my $file_appender = Log::Log4perl::Appender->new(
	                      "Log::Log4perl::Appender::File",
	                      name      => "filelog",
	                      filename  => sprintf("/tmp/%s.log", $loggerName));

	$file_appender->layout($layout);
	$logger->add_appender($file_appender);

 	my $self = {
    	_logger => $logger
    };

    bless $self, $class;
    return $self;
}

sub debug {
    my ($self, $message, @args) = @_;
    $self->{_logger}->debug(sprintf("[%3d] ".$message, threads->tid(), @args));
}

sub info {
    my ($self, $message, @args) = @_;
    $self->{_logger}->info(sprintf("[%3d] ".$message, threads->tid(), @args));
}

sub warn {
    my ($self, $message, @args) = @_;
    $self->{_logger}->warn(sprintf("[%3d] ".$message, threads->tid(), @args));
}

sub error {
    my ($self, $message, @args) = @_;
    $self->{_logger}->error(sprintf("[%3d] ".$message, threads->tid(), @args));
}

1;