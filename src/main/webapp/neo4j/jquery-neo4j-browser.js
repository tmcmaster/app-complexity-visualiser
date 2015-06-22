/**
 *  This is a JQuery Widget for browsing Neo4j data and graphing results with Almende.
 *
 *  There are a series of static functions at the start of the script,
 *  followed the widget. This was done to aid in removing as much state based logic
 *  from the JQuery Widget.
 */
(function(){
	/**
	 * Create a logger for the given element instance.
	 */
	function createInstanceLogger(element)
	{
		var elementName = element.attr('name');

		return function(message)
		{
		    console.log('Neo4jBrowser(' + (elementName === undefined ?  "" : elementName) + '):' + message);
		};
	}

 	/**
	 * JQuery Widget to manage expanding templates with data returned from REST calls.
	 */
	$.widget('tm.neo4j_browser', {

		element : undefined,

		options: {
		},

		log : null,

		_create: function () {
	        var self = this;

			// create a logger for this instance.
	        self.log = createInstanceLogger(this.element);
	        self.log('creating the Neo4j Browser.');

	        // Construct the Neo4j Controls component
	        $('fieldset[data-tm-type="neo4j-controls"]').neo4j_controls({
	        	cypherChanged : this._cypherChanged
	        });

	        // Construct the Neo4j Service component
	        $('fieldset[data-tm-type="neo4j-service"]').neo4j_service({
	        	newDataAvailable : this._newDataAvailable
	        });

	        // Construct the table component to view the data results
			$('div[data-tm-type="datatable"]').table();
	
			// Construct the graph component to graph the data results
			$('div[data-tm-type="almende"]').almende();

	        self.log('Neo4j Browser has been created.');
		},

		_newDataAvailable : function(data) {
			console.log('Service has given new data to the browser.');
			console.log('Browser is giving the data to the table.');
			$('div[data-tm-type="datatable"]').table('updateData', data);
			console.log('Browser is giving the data to the graph.');
			$('body').tabpane('selectTab', 'tabGraph');
			$('div[data-tm-type="almende"]').almende('updateData', data);
		},

		_cypherChanged : function(cypher) {
    		console.log('Controls have given a new cypher to the browser: ' + cypher);
    		console.log('Browser is giving the new cypher to the service: ' + cypher);
    		$('fieldset[data-tm-type="neo4j-service"]').neo4j_service('submitCypher', cypher);
    	},
	});

})();