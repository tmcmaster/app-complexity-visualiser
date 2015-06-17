#!/bin/bash

echo "";
echo "!! This script has hard coded paths that need to be fixed !!";
echo "";

if [ -t 0 ];
then
	echo "$@";
else
	cat;
#fi > /cygdrive/c/Users/Tim/Workspace/Neo4j/scratch/junk-stdin.cql
fi | /cygdrive/c/Apps/Java_7.1/bin/java -cp "c:/Program Files/Neo4j Community/bin/neo4j-desktop-2.2.2.jar" org.neo4j.shell.StartClient -v -port 1337 -file -
#/cygdrive/c/Apps/Java_7.1/bin/java -cp "c:/Program Files/Neo4j Community/bin/neo4j-desktop-2.2.2.jar" org.neo4j.shell.StartClient -v -port 1337 -file c:/Users/Tim/Workspace/Neo4j/scratch/junk-stdin.cql
