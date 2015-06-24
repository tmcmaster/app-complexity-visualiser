/**
 *  This is a JQuery Widget for managing tabular data.
 *
 *  There are a series of static functions at the start of the script,
 *  followed the widget. This was done to aid in removing as much state based logic
 *  from the JQuery Widget.
 */
(function(){

	var columns = [
		{ "title": "Engine" },
		{ "title": "Browser" },
		{ "title": "Platform" },
		{ "title": "Version", "class": "center" },
		{ "title": "Grade", "class": "center" }
	];

	var dataSet = [
		['Trident','Internet Explorer 4.0','Win 95+','4','X'],
		['Trident','Internet Explorer 5.0','Win 95+','5','C'],
		['Trident','Internet Explorer 5.5','Win 95+','5.5','A'],
		['Trident','Internet Explorer 6','Win 98+','6','A'],
		['Trident','Internet Explorer 7','Win XP SP2+','7','A'],
		['Trident','AOL browser (AOL desktop)','Win XP','6','A'],
		['Gecko','Firefox 1.0','Win 98+ / OSX.2+','1.7','A'],
		['Gecko','Firefox 1.5','Win 98+ / OSX.2+','1.8','A'],
		['Gecko','Firefox 2.0','Win 98+ / OSX.2+','1.8','A'],
		['Gecko','Firefox 3.0','Win 2k+ / OSX.3+','1.9','A'],
		['Gecko','Camino 1.0','OSX.2+','1.8','A'],
		['Gecko','Camino 1.5','OSX.3+','1.8','A'],
		['Gecko','Netscape 7.2','Win 95+ / Mac OS 8.6-9.2','1.7','A'],
		['Gecko','Netscape Browser 8','Win 98SE+','1.7','A'],
		['Gecko','Netscape Navigator 9','Win 98+ / OSX.2+','1.8','A'],
		['Gecko','Mozilla 1.0','Win 95+ / OSX.1+',1,'A'],
		['Gecko','Mozilla 1.1','Win 95+ / OSX.1+',1.1,'A'],
		['Gecko','Mozilla 1.2','Win 95+ / OSX.1+',1.2,'A'],
		['Gecko','Mozilla 1.3','Win 95+ / OSX.1+',1.3,'A'],
		['Gecko','Mozilla 1.4','Win 95+ / OSX.1+',1.4,'A'],
		['Gecko','Mozilla 1.5','Win 95+ / OSX.1+',1.5,'A'],
		['Gecko','Mozilla 1.6','Win 95+ / OSX.1+',1.6,'A'],
		['Gecko','Mozilla 1.7','Win 98+ / OSX.1+',1.7,'A'],
		['Gecko','Mozilla 1.8','Win 98+ / OSX.1+',1.8,'A'],
		['Gecko','Seamonkey 1.1','Win 98+ / OSX.2+','1.8','A'],
		['Gecko','Epiphany 2.20','Gnome','1.8','A'],
		['Webkit','Safari 1.2','OSX.3','125.5','A'],
		['Webkit','Safari 1.3','OSX.3','312.8','A'],
		['Webkit','Safari 2.0','OSX.4+','419.3','A'],
		['Webkit','Safari 3.0','OSX.4+','522.1','A'],
		['Webkit','OmniWeb 5.5','OSX.4+','420','A'],
		['Webkit','iPod Touch / iPhone','iPod','420.1','A'],
		['Webkit','S60','S60','413','A'],
		['Presto','Opera 7.0','Win 95+ / OSX.1+','-','A'],
		['Presto','Opera 7.5','Win 95+ / OSX.2+','-','A'],
		['Presto','Opera 8.0','Win 95+ / OSX.2+','-','A'],
		['Presto','Opera 8.5','Win 95+ / OSX.2+','-','A'],
		['Presto','Opera 9.0','Win 95+ / OSX.3+','-','A'],
		['Presto','Opera 9.2','Win 88+ / OSX.3+','-','A'],
		['Presto','Opera 9.5','Win 88+ / OSX.3+','-','A'],
		['Presto','Opera for Wii','Wii','-','A'],
		['Presto','Nokia N800','N800','-','A'],
		['Presto','Nintendo DS browser','Nintendo DS','8.5','C/A<sup>1</sup>'],
		['KHTML','Konqureror 3.1','KDE 3.1','3.1','C'],
		['KHTML','Konqureror 3.3','KDE 3.3','3.3','A'],
		['KHTML','Konqureror 3.5','KDE 3.5','3.5','A'],
		['Tasman','Internet Explorer 4.5','Mac OS 8-9','-','X'],
		['Tasman','Internet Explorer 5.1','Mac OS 7.6-9','1','C'],
		['Tasman','Internet Explorer 5.2','Mac OS 8-X','1','C'],
		['Misc','NetFront 3.1','Embedded devices','-','C'],
		['Misc','NetFront 3.4','Embedded devices','-','A'],
		['Misc','Dillo 0.8','Embedded devices','-','X'],
		['Misc','Links','Text only','-','X'],
		['Misc','Lynx','Text only','-','X'],
		['Misc','IE Mobile','Windows Mobile 6','-','C'],
		['Misc','PSP browser','PSP','-','C'],
		['Other browsers','All others','-','-','U']
	];


	var emptyTitles = [{ "title": "a" },{ "title": "b" }, { "title": "c" }, { "title": "d" }, { "title": "e" }];
	var emptyData = [];

	var emptyTitles2 = [{ "": "" }];
	var emptyData2 = [];

	function convertData(neoData)
	{
		console.log('About to convert data.');

		var columns = [{ "title": "AAA" }];
		var dataSet = [['1']];

		if (neoData !== undefined && neoData.data !== undefined && neoData.columns !== null)
		{
			if (neoData.data.length > 0 && neoData.data[0].length > 0)
			{
				var item = neoData.data[0][0];
				if (item.self !== undefined)
				{
					console.log('Data was not tabular data.');
				}
				else
				{
					columns = [];
					for (var c in neoData.columns)
					{
						columns.push({title: neoData.columns[c]});
					}
					dataSet = neoData.data;
				}
			}
			else
			{
				console.log('There were no results.');
			}
		}
		else
		{
			console.log('Data was not supplied.');
		}
		
		return {
			columns : columns,
			dataSet : dataSet
		}
	}

 	/**
	 * JQuery Widget to manage expanding templates with data returned from REST calls.
	 */
	$.widget('tm.table', {

		self : this,
		
		element : undefined,

		table : undefined,

		options: {
		},

		log : null,

		_create: function () {
		 	console.log('About to create DataTable');
	    	var self = this;

	    	self._updateData(emptyTitles2, emptyData2);

		    setTimeout(function() {
		    	self._updateData(columns, dataSet);
		    }, 3000);
		},
		updateData : function(newData) {
			console.log('Table has been given some more data to render.');

			var data = convertData(newData);
			if (data !== undefined)
			{
				this._updateData(data.columns, data.dataSet);
			}
		},
		_updateData : function(columns, dataSet)
	    {
	    	if (columns !== undefined && dataSet !== undefined)
	    	{
	    		console.log('Upddating the table.');
		    	console.log('Destroy existing table.');
		    	if (self.table !== undefined)
		    	{
		    		self.table.fnDestroy();
		    		$('div[data-tm-type="datatable"]').empty();
			    }

			    $('div[data-tm-type="datatable"]').html( '<table class="display dataTable" id="example"></table>' );
		    	console.log('Creating new table.');
		    	self.table = $('#example').dataTable({
			        "data": dataSet,
			        "columns": columns
			    } );
	    	}
	    }
	});

})();