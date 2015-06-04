#!/bin/bash

if [ "$1" == "--git" ];
then
	SCM=git;
	shift 1;
else
	SCM=hg;
fi
	
for i in `find $1 -name '*.java'`;
do
	if [ $SCM == "git" ];
	then
		git log --pretty=format:"%aN" $i
	else
		hg log --template "{author}" $i
	fi |awk '{printf("%s:%s\n","'$i'",$0)}' |sort |uniq -c |awk '{print substr($0,9) ":" $1}';
done
