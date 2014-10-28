/************************************
COMPARE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This handles generating the query to
solr in the compare pages for both the left and right columns.
The results from solr are run through a cocoon pipeline and displayed
via ajax.
************************************/

$(document).ready(function() {	

	var langStr = getURLParameter('lang');
	if (langStr == 'null'){
		var lang = '';
	} else {
		var lang = langStr;
	}
	// total options for advanced search - used for unique id's on dynamically created elements
	var total_options = 1;
	
	// activates the advanced search action
	$('.compare_button') .click(function () {
		var image = $('#image') .val();
		
		var query1 = assembleQuery('dataset1');
		var query2 = assembleQuery('dataset2');
		$.get('compare_results', {
			q : query1, start:0, image:image,  side:'1', mode: 'compare', lang: lang
		}, function (data) {
			$('#search1') .html(data);
		});
		// pass the query to the search_results url passing the needed url params:	
		$.get('compare_results', {
			q :query2, start:0, image:image, side:'2', mode: 'compare', lang: lang
		}, function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	
	function getURLParameter(name) {
	    return decodeURI(
	        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
	    );
	}
});


