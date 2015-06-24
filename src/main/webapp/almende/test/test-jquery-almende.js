$(document).ready(function() {

	var cyphers = [
		{
			title: 'Changes to packages per developer',
			cypher: "MATCH (r:Repository)-[rc]-(c:Changeset)-[cf]-(f:File) MATCH (c)-[cd]-(d:Developer) WHERE c.date > 'START_DATE' and c.date < 'END_DATE' return id(f) as pid, f.package as Package, id(d) as did, d.name as Developer ,sum(TOINT(cf.changes)) as Changes LIMIT 25",
			selected : 'true'
		},
		{
			title: 'Changeset between 2 dates',
			cypher: "MATCH (r:Repository)-[a]->(c:Changeset)-[b]-(d:Developer) WHERE c.date > 'START_DATE' and c.date < 'END_DATE' RETURN r,a,c,b,d LIMIT 25",
		},
		{
			title: 'Number of files changed, and changes made, per changeset',
			cypher: 'MATCH (r:Repository)-[rc]-(c:Changeset)-[cf]-(f:File) MATCH (c)-[cd]-(d:Developer) return d.name as Developer, c.name as Changeset, count(f) as Files,sum(TOINT(cf.changes)) as Changes'
		},
		{
			title: 'Changes to packages, by Developer, ordered by number of changes',
			cypher: 'MATCH (r:Repository)-[rc]-(c:Changeset)-[cf]-(f:File) MATCH (c)-[cd]-(d:Developer) return f.package as Package, d.name as Developer,sum(TOINT(cf.changes)) as Changes order by Package,Changes DESC'
		},
		{
			title: 'Process - Create a new Policy',
			cypher: "MATCH (ca:Class)-[c:CALLS]->(cb:Class) where ca.package =~ 'au.com.cgu.*' and cb.package =~ 'au.com.cgu.*' return id(ca) as FID, ca.name as FromClass, ca.package as FromPackage, id(cb) as TID, cb.name as ToClass,  cb.package as ToPackage, sum(toINT(c.duration)) as Duration order by FromClass, ToClass DESC LIMIT 500"
		}
	];


	var nodeBuilders = [
		{
			label: 'Set ID',
			build: function(node2, node2, relationship, value) {
				node.id = value
			}
		}
	];

	console.log('Adding cyphers');

	var templates = $('select[data-tm-type="neo4j-controls-cyphers"]');
    $(cyphers).each(function(cypher) {
        console.log(cyphers[cypher].title);
        $(templates).append($('<option ' + (cyphers[cypher].selected === undefined ? "" : "selected") + ' value="' + cyphers[cypher].cypher + '">' + cyphers[cypher].title + '</option>'));
    });	

	var newData = {
    		nodes : [{id:3, label:"a"}, {id:4, label:"b"}],
    		edges : [{from:3,to:4, value:10}]
	};

	$('div[data-tm-type="neo4j-browser"]').neo4j_browser();

});