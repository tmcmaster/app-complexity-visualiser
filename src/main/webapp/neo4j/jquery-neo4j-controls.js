/**
 *  This is a JQuery Widget for browsing Neo4j data and graphing results with Almende.
 *
 *  There are a series of static functions at the start of the script,
 *  followed the widget. This was done to aid in removing as much state based logic
 *  from the JQuery Widget.
 */
(function(){

	// add a formating function to the date object
	Date.prototype.yyyymmdd = function()
	{
		var yyyy = this.getFullYear();
		var mm = this.getMonth() < 9 ? "0" + (this.getMonth()+1) : (this.getMonth() + 1);
		var dd = this.getDate() < 9 ? "0" + this.getDate() : this.getDate();

		return "".concat(yyyy).concat('-').concat(mm).concat('-').concat(dd);
	};

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

	function updateTemporalRange()
	{
		var startPointString = $('input[data-tm-type="neo4j-controls-range"]').val();
		var startPoint = parseInt(startPointString);
		var months = parseInt($('input[data-tm-type="neo4j-controls-months"]').val());

		var startDate=new Date("2005-01-01");
		startDate.setMonth(startDate.getMonth()+startPoint);
		var startDateString = startDate.yyyymmdd();

		var endDate = new Date(startDate);
		endDate.setMonth(endDate.getMonth()+months);
		var endDateString = endDate.yyyymmdd();

		console.log('New date range: Start(' + startDateString + '), End(' + endDateString + ')');

		$('label[data-tm-type="neo4j-controls-start"]').text(startDateString);
		$('label[data-tm-type="neo4j-controls-end"]').text(endDateString);
	}

	function createGraph()
	{
		var newData = {
    		nodes : [{id:3, label:"a"}, {id:4, label:"b"}],
    		edges : [{from:3,to:4, value:10}]
		};

		setTimeout(function() {
			$('div[data-tm-type="almende"]').almende('updateData', newData);
		}, 5000);
	}

 	/**
	 * JQuery Widget to manage expanding templates with data returned from REST calls.
	 */
	$.widget('tm.neo4j_controls', {

		self : this,
		
		element : undefined,

		options: {
			cypherChanged : function() {
				console.log('Placehold for cypherChanged function has been called.');
			}
		},

		log : null,

		_create: function (options) {

			var self = this;
			if (options !== undefined)
			{
				if (options.cypherChanged !== undefined)
				{
					this.options.cypherChanged = options.cypherChanged;
				}
			}

	        var cypher = $('select[data-tm-type="neo4j-controls-cyphers"]').val();
	        $('input[data-tm-type="neo4j-controls-cypher"]').val(cypher);
	        $('select[data-tm-type="neo4j-controls-cyphers"]').change(function() {
	        	console.log("Cypher changed: " + $(this).val());
	        	$('input[data-tm-type="neo4j-controls-cypher"]').val($(this).val());
	        });

	        $('input[data-tm-type="neo4j-controls-months"]').change(function() {
		        updateTemporalRange();
	        });
	       	$('input[data-tm-type="neo4j-controls-range"]').change(function() {
		        updateTemporalRange();
	        });
	       	$('button[data-tm-type="neo4j-controls-create"]').click(function() {
	       		var cypher = $('input[data-tm-type="neo4j-controls-cypher"]').val();
	       		var startDate = $('label[data-tm-type="neo4j-controls-start"]').text();
	       		var endDate = $('label[data-tm-type="neo4j-controls-end"]').text();

	       		cypher = cypher.replace('START_DATE', startDate);
          		cypher = cypher.replace('END_DATE', endDate);

		        self.options.cypherChanged(cypher);
		        //createGraph();
	        });

	        updateTemporalRange();
		}
	});

})();
