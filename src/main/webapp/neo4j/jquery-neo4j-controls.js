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

			// initialise the cypher
	        var cypher = $('select[data-tm-type="neo4j-controls-cyphers"]').val();
	        $('input[data-tm-type="neo4j-controls-cypher"]').val(cypher);
			self._updateDataMapSelects();

			// listen for changes in the cypher list, and update the cypher field
	        $('select[data-tm-type="neo4j-controls-cyphers"]').change(function() {
	        	console.log("Cypher selection changed: " + $(this).val());
	        	$('input[data-tm-type="neo4j-controls-cypher"]').val($(this).val());
				self._updateDataMapSelects();
	        });

	        // listen for changes to the cypher, and update the DataMap select fields.
	        $('input[data-tm-type="neo4j-controls-cypher"]').change(function() {
	        	console.log("Cypher changed: " + $(this).val());
				self._updateDataMapSelects();
	        });

	        // listen for when the requested number of months changes, and update the end date.
	        $('input[data-tm-type="neo4j-controls-months"]').change(function() {
		        updateTemporalRange();
	        });

	        // listen for when the start point for the data range changes
	       	$('input[data-tm-type="neo4j-controls-range"]').change(function() {
		        updateTemporalRange();
	        });

	       	// listen for the request to build the graph and table views
	       	$('button[data-tm-type="neo4j-controls-create"]').click(function() {

          		var cypher = self._getCypher();
          		var dataMap = self._getDataMap();

		        self.options.cypherChanged(cypher, dataMap);
		        //createGraph();
	        });

	       	// initialise the start and end dates
	        updateTemporalRange();
		},

		_updateDataMapSelects : function() {
			console.log('Cypher has changed, so the DataMap select elements need to be rebuilt.');

			var cypher = $('input[data-tm-type="neo4j-controls-cypher"]').val();
			var indexReturn = cypher.indexOf(' return ');
			var optionsString = '<option value="-1">Default</option>';
			if (indexReturn > -1)
			{
				var start = (indexReturn + 8);
				var returnFields = cypher.substring(start);
				var indexOrderBy = returnFields.indexOf(' ORDER BY ');
				if (indexOrderBy < 0)
				{
					indexOrderBy = returnFields.indexOf(' order by ');
				}
				if (indexOrderBy > -1)
				{
					returnFields = returnFields.substring(0,indexOrderBy);
				}
				
				var indexLimit = returnFields.indexOf(' LIMIT ');
				if (indexLimit < 0)
				{
					indexLimit = returnFields.indexOf(' limit ');
				}
				if (indexLimit > -1)
				{
					returnFields = returnFields.substring(0,indexLimit);
				}

				var fieldStrings = returnFields.split(",");
				for (var f in fieldStrings)
				{
					var fieldString = fieldStrings[f];
					fieldString = fieldString.trim();
					var indexAs = fieldString.indexOf(' as ');
					if (indexAs > -1)
					{
						var start = (indexAs + 4)
						fieldString = fieldString.substring(start);
					}
					optionsString += '<option value="' + f + '">' + fieldString + '</option>';
					console.log("  - " + fieldString);
				}

				console.log('  - ' + optionsString);

				$('fieldset[data-tm-type="neo4j-datamap"]').find('select').each(function() {
					$(this).empty();
					$(this).html(optionsString);
				});
			}
		},

		_getCypher : function() {
			var cypher = $('input[data-tm-type="neo4j-controls-cypher"]').val();
			var startDate = $('label[data-tm-type="neo4j-controls-start"]').text();
			var endDate = $('label[data-tm-type="neo4j-controls-end"]').text();

			cypher = cypher.replace('START_DATE', startDate);
			cypher = cypher.replace('END_DATE', endDate);

			return cypher;
		},

		_getDataMap : function() {

			// node 1 valuea
			var indexIdNode1 = $('select[data-tm-type="neo4j-datamap-id-node1"]').val();
			var indexNameNode1 = $('select[data-tm-type="neo4j-datamap-name-node1"]').val();
			var indexGroupNode1 = $('select[data-tm-type="neo4j-datamap-group-node1"]').val();
			var indexValueNode1 = $('select[data-tm-type="neo4j-datamap-value-node1"]').val();

			// node 2 vaules
			var indexIdNode2 = $('select[data-tm-type="neo4j-datamap-id-node2"]').val();
			var indexNameNode2 = $('select[data-tm-type="neo4j-datamap-name-node2"]').val();
			var indexGroupNode2 = $('select[data-tm-type="neo4j-datamap-group-node2"]').val();
			var indexValueNode2 = $('select[data-tm-type="neo4j-datamap-value-node2"]').val();
			
			// relationship values
			var indexLabelRelationship = $('select[data-tm-type="neo4j-datamap-label-relationship"]').val();
			var indexValueRelationship = $('select[data-tm-type="neo4j-datamap-value-relationship"]').val();


			var dataMap = {
				// node 1 fields
				'idNode1' : indexIdNode1,
				'nameNode1' : indexNameNode1,
				'groupNode1' : indexGroupNode1,

				// node 2 fields
				'idNode2' : indexIdNode2,
				'nameNode2' : indexNameNode2,
				'groupNode2' : indexGroupNode2,

				// relationship
				'valueRelationship' : indexValueRelationship,
				'labelRelationship' : indexLabelRelationship
			};

			return dataMap;
		}
	});

})();
