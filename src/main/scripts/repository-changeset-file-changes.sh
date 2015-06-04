#!/bin/bash

if [ -z $1 ];
then
    echo "Repository directory required.";
    exit 1;
fi

if [ ! -d $1 ];
then
    echo "Repository directory invalid: $1";
    exit 2;
fi

cd $1;
hg log --stat | perl -e 'my $s,$f,$d,$c;while(<>){chomp($_);if($_=~m/^changeset:.*:(.*)/){$s=$1}elsif($_=~m/^user:\s+(.*)/){$d=$1}elsif($_=~m/\s+(.*?)\s+\|\s+([0-9]*)\s[+-]*/){$f=$1;$c=$2;printf("%s|%s|%s|%s\n",$s,$d,$f,$c);}}'
