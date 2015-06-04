USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:d:/work/Clone/app-complexity-visualiser/neo4j/changeset.csv" AS line
CREATE (c:Changeset {name:line.changeset,file:line.file,developer:line.developer,changes:line.changes,type:line.type,module:line.module,package:line.package,class:line.class,path:line.path});

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:d:/work/Clone/app-complexity-visualiser/neo4j/changeset.csv" AS line
MATCH (c:Changeset {name:line.changeset})
MATCH (r:Repository {name:line.repository})
MERGE (d:Developer {name:line.developer})
CREATE (r)-[:CONTAINS]->(c)
CREATE (c)-[:BELONGS_TO]->(r)
CREATE (c)-[:CREATED_BY]->(d)
CREATE (d)-[:CREATED]->(c);
