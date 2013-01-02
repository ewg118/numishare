$(document).ready(function () {
	$("#menu").menubar({
		autoExpand: true
	});
	
	$('.ui-menu-item').click(function(){
		var href = $(this).children('a').attr('href');
		
		window.location = href;
	});
	
});