/************************************
QUICKSEARCH
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
populates hidden query parameter in results page quick search
************************************/
$(document).ready(function() {
	$('#qs_form').submit(function() {
		assembleQuery();
	});

	function assembleQuery() {
		var search_text = $('#qs_text') .attr('value');
		var query = $('#qs_query').attr('value');
		if (search_text != null && search_text != '') {
			if (query == '*:*') {
				$('#qs_query') .attr('value', 'fulltext:' + search_text);
			} else {
				$('#qs_query') .attr('value', query + ' AND fulltext:' + search_text);
			}
		} else {
			$('#qs_query') .attr('value', '*:*');
		}
	}
});