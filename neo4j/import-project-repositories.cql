USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:d:/work/Clone/app-complexity-visualiser/neo4j/project.csv" AS line
CREATE (p:Project {name:line.name});

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:d:/work/Clone/app-complexity-visualiser/neo4j/repository.csv" AS line
CREATE (r:Repository {name:line.name,type:line.type,path:line.path});

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:d:/work/Clone/app-complexity-visualiser/neo4j/repository.csv" AS line
MATCH (r:Repository {name:line.name,type:line.type,path:line.path})
MATCH (p:Project {name:line.project})
CREATE (p)-[:CONTAINS]->(r)
CREATE (r)-[:BELONGS_TO]->(p);
