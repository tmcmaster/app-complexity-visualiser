package Complexity::Path;

use Exporter qw(import);

our @EXPORT = qw(getDirectoryPlusArgs getNameForPath splitPath generateChildPath);

sub getDirectoryPlusArgs
{
	my @args = @_;

	my $dir;
	if ($#args eq -1)
	{
		$dir = `pwd`;
	}
	else
	{
		$dir = $args[0];
	}

	if ($dir =~ m/\/$/)
	{
		chop($dir);
	}

	unless (-d $dir)
	{
		die "Given directory was invalid: $dir";
	}

	$dir = `(cd $dir; pwd)`;
	chomp($dir);

	return ($dir, @ARGV[1..$#ARGV]);
}

sub getNameForPath
{
	my ($path) = @_;

	if ($path =~ m/.*\/$/) { chop($path); }

	my ($name) = ($path =~ m/\// ? $path =~ m/.*\/(.*)/ : $path);
	
	return $name;
}

sub generateChildPath
{
	my ($baseDir,$relativePath,$name) = @_;

	my $childPath;
	unless ($relativePath eq "")
	{
		$childPath = sprintf("%s/%s/%s", $baseDir, $relativePath, $name);
	}
	else
	{
		my  $parentName = ($baseDir =~ m/.*\/(.*?)/ ? $1 : $baseDir);
		$childPath = ($parentName eq $name ? $baseDir : sprintf("%s/%s", $baseDir, $name));
	}

	return $childPath;
}

#
# returns (baseDir,relativePath,name,file)
#
sub splitPath
{
	my ($baseDir, $path) = @_;

	# remove trailing slash, if there
	if ($baseDir =~ m/.*\/$/) { chop($baseDir); }
	if ($path =~ m/.*\/$/) { chop($path); }

	my ($pathDir, $pathFile) = $path =~ m/(.*)\/(.*)/;

	my ($relativePathDir) = ($baseDir eq $pathDir ? ("") : $pathDir =~ m/$baseDir\/(.*)/);

	my ($namePath) = ($relativePathDir eq "" ? $baseDir : $relativePathDir);
	my ($name) = ($namePath =~ m/\// ? $namePath =~ m/.*\/(.*)/ : $namePath);

	return ($baseDir, $relativePathDir, $name, $pathFile);
}

1;
