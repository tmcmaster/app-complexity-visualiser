/**
 *  This is a JQuery Widget for interaction with the Neo4j REST service.
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
		    console.log('Neo4jControls(' + (elementName === undefined ?  "" : elementName) + '):' + message);
		};
	}


 	/**
	 * JQuery Widget to manage expanding templates with data returned from REST calls.
	 */
	$.widget('tm.neo4j_service', {

		self : this,
		
		element : undefined,

		options: {
			newDataAvailable : function() {
				console.log('Placehold for newDataAvailable function has been called.');
			}
		},

		log : null,

		_create: function (options) {

			var self = this;
			if (options !== undefined)
			{
				if (options.newDataAvailable !== undefined)
				{
					this.options.newDataAvailable = options.newDataAvailable;
				}
			}
		},

		submitCypher : function(cypher, dataMap) {
			var self = this;
			console.log('Posting cypher to Neo4j: ' + cypher);
			$.ajax({
				type: "POST",
				url:'http://localhost:7474/db/data/cypher',
				data:{ query : cypher },
				success: function(data) {
					self.options.newDataAvailable(data, dataMap);
				}
			 });

			// setTimeout(function() {
			// 	self.options.newDataAvailable();
			// }, 5000);
		}
	});

})();