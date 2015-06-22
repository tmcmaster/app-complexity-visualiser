// $(document).ready(function() {
// 	$("#content > div").hide(); // Hide all content
// 	$("#tabs li:first").attr("id","current"); // Activate the first tab
// 	$("#content #tabQuery").fadeIn(); // Show first tab's content

// 	$('#tabs a').click(function(e) {
// 		e.preventDefault();
// 		if ($(this).closest("li").attr("id") == "current")
// 		{ //detection for current tab
// 		 	return;       
// 		}
// 		else
// 		{             
// 		  $("#content > div").hide(); // Hide all content
// 		  $("#tabs li").attr("id",""); //Reset id's
// 		  $(this).parent().attr("id","current"); // Activate this

// 		  console.log('Selecting tab: '  + $(this).attr('name'));
// 		  $('#' + $(this).attr('name')).fadeIn(); // Show content for the current tab
// 		}
// 	});
// });
