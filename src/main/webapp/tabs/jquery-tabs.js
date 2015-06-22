/**
 *  This is a JQuery Widget for managing tabbed content.
 *
 *  There are a series of static functions at the start of the script,
 *  followed the widget. This was done to aid in removing as much state based logic
 *  from the JQuery Widget.
 */
(function(){


 	/**
	 * JQuery Widget to manage expanding templates with data returned from REST calls.
	 */
	$.widget('tm.tabpane', {

		self : this,
		
		element : undefined,

		options: {
		},

		log : null,

		_create: function () {

			$("#content > div").hide(); // Hide all content
			$("#tabs li:first").attr("id","current"); // Activate the first tab
			$("#content #tabQuery").fadeIn(); // Show first tab's content

			var self = this;
			$('#tabs a').click(function(e) {
				e.preventDefault();
				if ($(this).closest("li").attr("id") == "current")
				{ //detection for current tab
				 	return;       
				}
				else
				{   
					var name = $(this).attr('name');  
					self.selectTab(name);        
				}
			});				
			self.selectTab('tabTable');
		},

		selectTab : function(name) {
			$("#content > div").hide(); // Hide all content
			$("#tabs li").attr("id",""); //Reset id's
			var selectString = 'a[name=' + name + ']';
			$(selectString).parent().attr("id","current"); // Activate this

			console.log('Selecting tab: '  + name);
			$('#' + name).fadeIn(); // Show content for the current tab
		}
	});

})();