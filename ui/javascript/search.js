/************************************
SEARCH
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Portions of this originally authored by Matt Mitchell.
Modified heavily to handle the search form functionality
and piecing together the search query.
************************************/
$(document).ready(function() {	
	$('#advancedSearchForm').submit(function() {
		var q = assembleQuery('advancedSearchForm');
		$('#q_input') .attr('value', q);
	});
});