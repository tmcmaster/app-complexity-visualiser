#!/usr/bin/perl

use strict;

my %classMap = {};

my $line;
for $line (`./module-classes.pl $ARGV[0]`)
{
	chomp($line);
	if ($line =~ m/^class/)
	{
		my @parts = split(',', $line);
		my ($class,$package) = @parts[1,3];
		$classMap{$class} = $package;
	}
}

printf("Test Class,Test Class Package,Expected Package\n");
for $line (`./module-classes.pl --test-classes $ARGV[0]`)
{
	chomp($line);
	if ($line =~ m/^class/)
	{
		my @parts = split(',', $line);
		my ($testClass,$testPackage) = @parts[2,4];
		$testClass =~ m/(.*)(Test|IntegrationTest)/;
		my $class = $2;
		#printf("class: %s, package: %s, name: %s\n", $testClass, $testPackage, $class);
		if (defined $classMap{$class})
		{
			my $package = $classMap{$class};
			my $expectedPackage = $package . ".test";
			if ($expectedPackage ne $testPackage)
			{
				printf("%s,%s,%s\n", $testClass, $testPackage, $expectedPackage);
			}
		}
		else
		{
			printf("%s,%s,\n", $testClass, $testPackage);
		}
	}
}
