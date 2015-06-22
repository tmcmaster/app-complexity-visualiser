$(document).ready(function() {

	var cyphers = [
		{
			title: 'Changes to packages per developer',
			cypher: 'MATCH (r:Repository)-[rc]-(c:Changeset)-[cf]-(f:File) MATCH (c)-[cd]-(d:Developer) return f.package as Package,d.name as Developer ,sum(TOINT(cf.changes)) as Changes',
		},
		{
			title: 'Changeset between 2 dates',
			cypher: "MATCH (r:Repository)-[a]->(c:Changeset)-[b]-(d:Developer) WHERE c.date > 'START_DATE' and c.date < 'END_DATE' RETURN r,a,c,b,d",
			selected : 'true'
		},
		{
			title: 'Number of files changed, and changes made, per changeset',
			cypher: 'MATCH (r:Repository)-[rc]-(c:Changeset)-[cf]-(f:File) MATCH (c)-[cd]-(d:Developer) return d.name as Developer, c.name as Changeset, count(f) as Files,sum(TOINT(cf.changes)) as Changes'
		},
		{
			title: 'Changes to packages, by Developer, ordered by number of changes',
			cypher: 'MATCH (r:Repository)-[rc]-(c:Changeset)-[cf]-(f:File) MATCH (c)-[cd]-(d:Developer) return f.package as Package, d.name as Developer,sum(TOINT(cf.changes)) as Changes order by Package,Changes DESC'
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

	//console.log('Updating data.');
	$('div[data-tm-type="neo4j-browser"]').neo4j_browser();
	$('body').tabpane();

	//$('div[data-tm-type="almende"]').almende('updateData', newData);

});