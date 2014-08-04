/************************************
IMAGES AVAILABLE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
checkbox to turn on or off the images requirement in the result solr query
************************************/
$(function () {
	$('#imagesavailable') .click(function () {
		var query = $(this).attr('value');	
		if($('#imagesavailable:checked').val() !== undefined){
			var new_query = query + ' AND imagesavailable:true';
			location.href = 'results?q=' + new_query;
		} else {
			var new_query = query.replace(' AND imagesavailable:true', '');
			location.href = 'results?q=' + new_query;
		}
	});
});