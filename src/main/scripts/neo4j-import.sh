#!/bin/bash

echo "";
echo "!! This script has hard coded paths that need to be fixed !!";
echo "";

if [ "$1" == "--force" ];
then
	echo "removing database lock: /cygdrive/c/Users/Tim/Workspace/Neo4j/db/scratch/lock";
	rm /cygdrive/c/Users/Tim/Workspace/Neo4j/db/scratch/lock;
fi

if [ -f /cygdrive/c/Users/Tim/Workspace/Neo4j/db/scratch/lock ];
then
	echo "The database needs to be shutdown: /cygdrive/c/Users/Tim/Workspace/Neo4j/db/scratch";
	exit 1;
fi

/cygdrive/c/Apps/Java_7.1/bin/java -cp "c:/Program Files/Neo4j Community/bin/neo4j-desktop-2.2.2.jar" org.neo4j.shell.StartClient -v -path c:/Users/Tim/Workspace/Neo4j/db/scratch -file c:/Users/Tim/Workspace/Neo4j/scratch/import.cql
