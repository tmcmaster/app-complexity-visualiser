@echo off

if "%1"=="" goto usage
if "%2"=="" goto usage

C:/Apps/Java_7.1/bin/java -jar "c:/Program Files/Neo4j Community/bin/neo4j-desktop-2.0.3.jar" org.neo4j.shell.StartClient -v -path %1 file %2
rem D:\work\tools\Neo4j\jre\bin\java -cp D:\work\tools\Neo4j\bin\neo4j-desktop-2.2.2.jar org.neo4j.shell.StartClient -v -path d:\work\neo4j\%1 -file %2
goto end

:usage
@echo "Usage: %0 [database] [script]"

:end
