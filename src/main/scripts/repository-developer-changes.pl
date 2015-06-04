#!/usr/bin/perl


my $cypher = 'MATCH (r:Repository)-[a]->(c:Changeset)-[b]-(d:Developer) WHERE (c.inserts > "0" or c.deletes > "0") return d.name, sum(TOINT(c.inserts)) as inserts, sum(TOINT(c.deletes)) as deletes order by inserts DESC';

my $cypher2 = 'MATCH (r:Repository)-[a]->(c:Changeset)-[b]-(d:Developer) WHERE (c.inserts > "0" or c.deletes > "0") return d.name, sum(TOINT(c.inserts)) as inserts, sum(TOINT(c.deletes)) as deletes, TOINT(c.deletes)+TOINT(c.inserts) as changes order by inserts DESC';

