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
});