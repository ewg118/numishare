/************************************
SORT FIRST COMPARISON DATASET
Written by Ethan Gruber, ewg4x@virginia.edu
Library: jQuery
Description: Used to generate the query for searching 
on a selected query for the first dataset in the comparison
mode.
************************************/
$(function () {
	$('#search1 .sortForm_categories') .change(function(){
		var category = $(this) .attr('value');
		var sort_order = $('#search1 .sortForm_order') .attr('value');
		if (category != 'null'){
			$('#search1 .sort_button') .removeAttr('disabled');
			$('#search1 .sort_param') .attr('value', category + ' ' + sort_order);
		}
		else {
			$('#search1 .sort_button') .attr('disabled', 'disabled');
		}
	});
	
	$('#search1 .sortForm_order') .change(function(){
		var sort_order = $(this) .attr('value');
		var category = $('#search1 .sortForm_categories') .attr('value');
		$('#search1 .sort_param') .attr('value', category + ' ' + sort_order);
	});
	
	$('#search1 .sort_button') .click(function () {
		var image = $('#image') .attr('value');
		var query = $('#search1 input[name=q]') .attr('value');
		var sort = $('#search1 .sortForm_categories') .attr('value') + ' ' + $('#search1 .sortForm_order') .attr('value');
		$.get('compare_results', {
			q : query, start:0, image:image, side: '1', mode:  'compare', sort: sort
		},
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
});