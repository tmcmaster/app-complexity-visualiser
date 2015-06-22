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

	function convertData(neoData)
	{
        console.log('About to convert data.');
		var data = {
			nodes : [],
			edges : []
		};

		var nodeMap = {};
		var relationshipMap = {};

		for (var i in neoData.data)
		{
			if (i > 10) break;
			
			for (var j in neoData.data[i])
			{
				var subList = neoData.data[i];
				var item  = subList[j];
		        if (item.self)
		        {
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
		        else
		        {
					var item = subList;
					var node1 = {
						id:item[0],
						label: item[1],
						group: item[1]
					};

					if (nodeMap[node1.id] === undefined)
					{
						nodeMap[node1.id] = node1;
						data.nodes.push(node1);
					}
					var node2 = {
						id:item[2],
						label: item[3],
						group: item[1]
					};

					if (nodeMap[node2.id] === undefined)
					{
						nodeMap[node2.id] = node2;
						data.nodes.push(node2);
					}

					var relationship = {
						id: (i*1000 + j),
						from: node1.id,
						to: node2.id
					};
					data.edges.push(relationship);
		        }
			}
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
	    updateData : function(newData)
	    {
	    	if (newData !== undefined)
	    	{
	    		this.log('Upddating the graph.');
		    	var data = convertData(newData);
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
