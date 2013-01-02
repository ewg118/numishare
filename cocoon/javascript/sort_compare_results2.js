/************************************
SORT SECOND COMPARISON DATASET
Written by Ethan Gruber, ewg4x@virginia.edu
Library: jQuery
Description: Used to generate the query for searching 
on a selected query for the second dataset in the comparison
mode.
************************************/
$(function () {
	$('#search2 .sortForm_categories') .change(function(){
		var category = $(this) .attr('value');
		var sort_order = $('#search2 .sortForm_order') .attr('value');
		if (category != 'null'){
			$('#search2 .sort_button') .removeAttr('disabled');
			$('#search2 .sort_param') .attr('value', category + ' ' + sort_order);
		}
		else {
			$('#search2 .sort_button') .attr('disabled', 'disabled');
		}
	});
	
	$('#search2 .sortForm_order') .change(function(){
		var sort_order = $(this) .attr('value');
		var category = $('#search2 .sortForm_categories') .attr('value');
		$('#search2 .sort_param') .attr('value', category + ' ' + sort_order);
	});
	
	$('#search2 .sort_button') .click(function () {
		var image = $('#image') .attr('value');
		var query = $('#search2 input[name=q]') .attr('value');
		var sort = $('#search2 .sortForm_categories') .attr('value') + ' ' + $('#search2 .sortForm_order') .attr('value');
		$.get('compare_results', {
			q : query, start:0, image:image, side: '1', mode:  'compare', sort: sort
		},
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
});