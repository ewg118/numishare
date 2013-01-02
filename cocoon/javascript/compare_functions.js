/************************************
COMPARE AJAX FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
These are a series of functions for pagination, selection, and sorting of queries in the compare section.
************************************/
$(document).ready(function () {
	
	/*** return to search results from item record ***/
	$(' #search1 .back_results') .livequery('click', function (event) {
		var href = $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search2 .back_results') .livequery('click', function (event) {
		var href = $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	
	/*** pagination ***/
	$(' #search1 .comparepagingBtn') .livequery('click', function (event) {
		var href = $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search2 .comparepagingBtn') .livequery('click', function (event) {
		var href = $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	/*** select record for comparison ***/
	$(' #search1 .compare') .livequery('click', function (event) {
		$.get($(this) .attr('href'), {
		},
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search2 .compare') .livequery('click', function (event) {
		$.get($(this) .attr('href'), {
		},
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	
	/*** sort results ***/
	//column 1
	$('#search1 .sortForm_categories') .livequery('change', function (event) {
		var category = $(this) .attr('value');
		var sort_order = $('#search1 .sortForm_order') .attr('value');
		if (category != 'null') {
			$('#search1 #sort_button') .removeAttr('disabled');
			$('#search1 .sort_param') .attr('value', category + ' ' + sort_order);
		} else {
			$('#search1 #sort_button') .attr('disabled', 'disabled');
		}
	});
	
	$('#search1 .sortForm_order') .livequery('change', function (event) {
		var sort_order = $(this) .attr('value');
		var category = $('#search1 .sortForm_categories') .attr('value');
		$('#search1 .sort_param') .attr('value', category + ' ' + sort_order);
	});
	
	$('#search1 #sort_button') .livequery('click', function (event) {
		var image = $('#image') .attr('value');
		var query = $('#search1 input[name=q]') .attr('value');
		var sort = $('#search1 .sortForm_categories') .attr('value') + ' ' + $('#search1 .sortForm_order') .attr('value');
		$.get('compare_results', {
			q: query, start: 0, image: image, side: '1', mode: 'compare', sort: sort
		},
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	//column 2
	$('#search2 .sortForm_categories') .livequery('change', function (event) {
		var category = $(this) .attr('value');
		var sort_order = $('#search2 .sortForm_order') .attr('value');
		if (category != 'null') {
			$('#search2 #sort_button') .removeAttr('disabled');
			$('#search2 .sort_param') .attr('value', category + ' ' + sort_order);
		} else {
			$('#search2 #sort_button') .attr('disabled', 'disabled');
		}
	});
	
	$('#search2 .sortForm_order') .livequery('change', function (event) {
		var sort_order = $(this) .attr('value');
		var category = $('#search2 .sortForm_categories') .attr('value');
		$('#search2 .sort_param') .attr('value', category + ' ' + sort_order);
	});
	
	$('#search2 #sort_button') .livequery('click', function (event) {
		var image = $('#image') .attr('value');
		var query = $('#search2 input[name=q]') .attr('value');
		var sort = $('#search2 .sortForm_categories') .attr('value') + ' ' + $('#search2 .sortForm_order') .attr('value');
		$.get('compare_results', {
			q: query, start: 0, image: image, side: '1', mode: 'compare', sort: sort
		},
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	
	/*** toggle options ***/
	$('.category_list') .livequery('change', function (event) {
		var parentid = '#' + $(this) .parent() .attr('id');
		var dataset = '#' + $(this) .parent() .parent() .attr('id');
		
		var selected_id = $(this) .children("option:selected") .attr('id');
		if (selected_id == 'keyword_option' || selected_id == 'persname_option' || selected_id == 'geogname_option' || selected_id == 'deity_option' || selected_id == 'legend_option' || selected_id == 'type_option' || selected_id == 'subject_option' || selected_id == 'identifier_option' || selected_id == 'color_option' || selected_id == 'reference_option') {
			if ($(this) .parent('.searchItemTemplate') .children('.option_container') .children('input') .attr('class') != 'search_text') {
				$(this) .parent('.searchItemTemplate') .children('.option_container') .html('');
				$(this) .parent('.searchItemTemplate') .children('.option_container') .html('<input type="text" id="search_text" class="search_text"/>');
			}
		}
		//YEAR
		else if (selected_id == 'year_option') {
			$(this) .parent() .children('.option_container') .html('From: <input type="text" class="from_date"/>' +
			'<select class="from_era"><option value="minus">B.C.</option><option value="" selected="selected">A.D.</option></select>' +
			'To: <input type="text" class="to_date"/>' +
			'<select class="to_era"><option value="minus">B.C.</option><option value="" selected="selected">A.D.</option></select>');
		}
		//WEIGHT
		else if (selected_id == 'weight_option') {
			$(this) .parent('.searchItemTemplate') .children('.option_container') .html('<select class="weight_range">' +
			'<option value="lessequal">Less/Equal to</option><option value="equal">Equal to</option><option value="greaterequal">Greater/Equal to</option>' +
			'</select><input type="text" class="weight_int"/> grams');
		}
		//DIMENSIONS
		else if (selected_id == 'dimensions_option') {
			$(this) .parent('.searchItemTemplate') .children('.option_container') .html('<select class="dimensions_range">' +
			'<option value="lessequal">Less/Equal to</option><option value="equal">Equal to</option><option value="greaterequal">Greater/Equal to</option>' +
			'</select><input type="text" class="dimensions_int"/> mm');
		} else {
			var category = $(this) .children("option:selected") .attr('value');
			$(this) .parent('.searchItemTemplate') .children('.option_container') .html('<img style="margin-left:100px;margin-right:100px;" src="images/ajax-loader.gif"/>');
			$.get('get_search_facets', {
				q: category + ':[* TO *]' + ' AND imagesavailable:true', category: category
			},
			function (data) {
				$(dataset) .children(parentid) .children('.option_container') .html(data);
			});
		}
	});
});