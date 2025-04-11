/************************************
SEARCH
Written by Ethan Gruber, egruber@numismatics.org
Date Modified: April 2025
Library: jQuery
Description: Portions of this originally authored by Matt Mitchell.
Modified heavily to handle the search form functionality
and piecing together the search query.
************************************/
$(document).ready(function() {	
    
    //assemble query on form submission
	$('#facet_form').submit(function() {
		var q = getQuery();
        $('#facet_form_query').attr('value', q);
	});
});