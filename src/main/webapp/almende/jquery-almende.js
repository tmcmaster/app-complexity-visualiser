/**
 *  This is a JQuery Widget for managing Almende Graphing,
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
		    console.log('Almende(' + elementName + '):' + message);
		};
	}

	function convertData(neoData, fields)
	{
        console.log('About to convert data.');
		var data = {
			nodes : [],
			edges : []
		};

		var nodeMap = {};
		var relationshipMap = {};

		if (neoData !== undefined && neoData.data !== undefined && neoData.data.length > 0 && neoData.data[0].length > 0)
		{
			if (neoData.data[0][0].self !== undefined)
			{
				// parse node and relationship data
				for (var i in neoData.data)
				{
					for (var j in neoData.data[i])
					{
						var item  = neoData.data[i][j];
						if (item.self.indexOf('data/node') !== -1)
						{
							var match = /.*\/node\/([0-9]*)/.exec(item.self);
							var node = {
								id:match[1],
								label: item.data.name.substring(0,10),
								group: item.metadata.labels[0]
							};
							if (nodeMap[node.id] === undefined)
							{
								nodeMap[node.id] = node;
								data.nodes.push(node);
							}
						}
						else if (item.self.indexOf('data/relationship') !== -1)
						{
							var match = /.*\/relationship\/([0-9]*)/.exec(item.self);
							var relationshipId = match[1];
							var fromId = /.*\/node\/([0-9]*)/.exec(item.start)[1];
							var toId = /.*\/node\/([0-9]*)/.exec(item.end)[1];
							var relationshipId = match[1];
							var relationship = {
								id: relationshipId,
								from: fromId,
								to: toId
							};
							if (relationshipMap[relationship.id] === undefined)
							{
								relationshipMap[relationship.id] = relationship;
								data.edges.push(relationship);
							}
						}
					}
				}
			}
			else if (fields.idNode1 >  -1 && fields.idNode2 > -1)
			{
				// parse tabular data
				for (var i in neoData.data)
				{
					var item = neoData.data[i];

					var node1 = {
						id: item[fields.idNode1],
						label: "" + item[(fields.nameNode1 < 0 ? fields.idNode1 : fields.nameNode1)],
						group: "" + (fields.groupNode1 < 0 ? "group" : item[fields.groupNode1])
					};

					if (nodeMap[node1.id] === undefined)
					{
						nodeMap[node1.id] = node1;
						data.nodes.push(node1);
					}

					var node2 = {
						id:item[fields.idNode2],
						label: "" + item[(fields.nameNode2 < 0 ? fields.idNode2 : fields.nameNode2)],
						group: "" + (fields.groupNode2 < 0 ? "group" : item[fields.groupNode2])
					};

					if (nodeMap[node2.id] === undefined)
					{
						nodeMap[node2.id] = node2;
						data.nodes.push(node2);
					}

					var relationship = {
						id: (i*1000),
						from: node1.id,
						to: node2.id,
						value: (fields.valueRelationship < 0 ? 1 : item[fields.valueRelationship]),
						label: "" + (fields.labelRelationship < 0 ? "" : item[fields.labelRelationship])
					};
					data.edges.push(relationship);
				}
			}
			else
			{
				console.log('Invalid data. Not able to graph.');
			}
		}
		else
		{
			console.log('Data was not supplied.');
		}

	
		console.log('Data has been converted.');

		return data;
	}

 	/**
	 * JQuery Widget to manage expanding templates with data returned from REST calls.
	 */
	$.widget('tm.almende', {

		self : this,
		element : undefined,
		options: {
		},

		log : null,

		config : {
  			configure : {enabled:true,filter:'node'}
		},

		data : {
    		nodes : [{id:1, name:"a"}, {id:2, name:"b"}],
    		edges : [{from:1,to:2}]
		},

		network : undefined,
		
		_create: function () {
			var self = this;
			this.self = this;

			self.element = this.element;

			// create a logger for this instance.
	        self.log = createInstanceLogger(this.element);

	        self.log('Created Almende widget.');

	        //self._recreateNetwork();
	    },
	    updateData : function(newData, dataMap)
	    {
	    	if (newData !== undefined)
	    	{
	    		this.log('Upddating the graph.');
		    	var data = convertData(newData, dataMap);
		    	this._recreateNetwork(data);
		    }

	    },
	    _recreateNetwork : function(data) {
			var self = this;
			if (self.network !== undefined)
  			{
  				self.network.destroy();
  				self.network = undefined;
  			}
			self.network = new vis.Network(this.element.get(0), data, this.config);
	    }
	});

	console.log('Looking for Almende elements.');
	$(document).ready(function() {
		$('div[data-tm-type="almende"]').almende();
	});

})();
