package Complexity::Logging;

use Exporter qw(import);

our @EXPORT = qw(getLogger createLogger getOrCreateLogger logdie);

use Log::Log4perl;
use Log::Log4perl::Layout;
use Log::Log4perl::Level;

my $defaultLogLevel = $DEBUG;
my $LOGGER;

sub createLogger
{
	my ($loggerName, $logLevel) = @_;

	$logLevel = (defined $logLevel ? $logLevel : $defaultLogLevel);

	$LOGGER = Log::Log4perl->get_logger($loggerName);
	$LOGGER->level($logLevel);

	# Define a layout
	my $layout = Log::Log4perl::Layout::PatternLayout->new("[%-5p] %d  - %M(%L)[%P] %m%n");

	# Define a file appender
	my $file_appender = Log::Log4perl::Appender->new(
	                      "Log::Log4perl::Appender::File",
	                      name      => "filelog",
	                      filename  => sprintf("/tmp/%s.log", $loggerName));

	$LOGGER->add_appender($file_appender);
	$file_appender->layout($layout);

	return $LOGGER;
}

sub getOrCreateLogger
{
	my ($loggerName, $logLevel) = @_;

	if (defined $LOGGER)
	{
		return $LOGGER;
	}
	else
	{
		return createLogger($loggerName, $logLevel);
	}
}

sub getLogger
{
	die "Logger has not been configured. call createLogger(loggerName, logLevel)" unless (defined $LOGGER); 
	
	return $LOGGER;
}

sub logdie
{
	my ($message) = @_;
	$LOGGER->error($message."\n");
	die $message;
}

1;