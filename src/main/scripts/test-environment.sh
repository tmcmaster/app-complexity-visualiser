#!/bin/bash
#
# $HOME/.cpan/CPAN/MyConfig.pm
#
# $CPAN::Config = {
#   'ftp_passive' => q[1],
#   'ftp_proxy' => q[http://proxy.auiag.corp:8080],
#   'http_proxy' => q[http://proxy.auiag.corp:8080],
# };
#
# Libs:libcrypt-devel

echo "";
echo "Checking for required Perl modules.....";
for module in JSON::Parse
do
    (perl -e 'use '$module'' > /dev/null 2>&1 ) && printf "%-40s OK\n" $module || printf "%-40s MISSING!\n" $module;
done

echo "";
echo "Checking for required applications.....";
for application in make gcc g++ curl
do
    (which $application > /dev/null 2>&1) && printf "%-40s OK\n" $application || printf "%-40s MISSING!\n" $application;
done
echo "";
