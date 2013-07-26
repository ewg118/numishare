/***********************
MAP FUNCTIONS FOR FULLSCREEN
Description: Fancybox options for fullscreen map
***********************/
$(document).ready(function(){
	$('#show_filters').fancybox();
	$('#close').click(function(){
		$.fancybox.close();
	});
	$('a.thumbImage').livequery(function(){
		$(this).fancybox();
	});
});