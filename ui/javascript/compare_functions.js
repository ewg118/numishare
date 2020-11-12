/************************************
COMPARE AJAX FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
These are a series of functions for pagination, selection, and sorting of queries in the compare section.
************************************/
$(document).ready(function () {
	
	var langStr = getURLParameter('lang');
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	/*** return to search results from item record ***/
	$(' #search1') .on('click', '.compare_options small .back_results', function () {
		var href = $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search2') .on('click', '.compare_options small .back_results', function () {
		var href = $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	
	/*** pagination ***/
	$(' #search1') .on('click', '.paging_div .page-nos .btn-toolbar .pagination .pagingBtn', function () {
		var href = 'compare_results' + $(this) .attr('href');		
		$.get(href,
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search2') .on('click', '.paging_div .page-nos .btn-toolbar .pagination .pagingBtn', function () {
		var href = 'compare_results' + $(this) .attr('href');
		$.get(href,
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	/*** select record for comparison ***/
	$(' #search1') .on('click', '.result-doc div h4 .compare', function () {
		var href = $(this) .attr('href');
		$.get(href,
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search2') .on('click', '.result-doc div h4 .compare', function () {
		var href = $(this) .attr('href');
		$.get(href,
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	
	/*** sort results ***/
	//column 1
	$(' #search1') .on('change', 'div div .sortForm .sortForm_categories', function () {
		var field = $(this).val();
		var sort_order = $(this).next('.sortForm_order').val();
		setValue(field, sort_order, 'search1');
	});
	$(' #search1') .on('change', 'div div .sortForm .sortForm_order', function () {
		var field = $(this).prev('.sortForm_categories').val();
		var sort_order = $(this).val();
		setValue(field, sort_order, 'search1');
	});
	
	$(' #search1') .on('click', 'div div .sortForm .sort_button', function () {
		var image = $('#image') .val();
		var query = $('#search1 input[name=q]') .val();
		var sort = $('#search1 input[name=sort]') .val();
		$.get('compare_results', {
			q: query, start: 0, image: image, side: '1', mode: 'compare', sort: sort, lang: lang
		},
		function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	//column 2
	$(' #search2') .on('change', 'div div .sortForm .sortForm_categories', function () {
		var field = $(this).val();
		var sort_order = $(this).next('.sortForm_order').val();
		setValue(field, sort_order, 'search2');
	});
	$(' #search2') .on('change', 'div div .sortForm .sortForm_order', function () {
		var field = $(this).prev('.sortForm_categories').val();
		var sort_order = $(this).val();
		setValue(field, sort_order, 'search2');
	});
	
	$(' #search2') .on('click', 'div div .sortForm .sort_button', function () {
		var image = $('#image') .val();
		var query = $('#search2 input[name=q]') .val();
		var sort = $('#search2 input[name=sort]') .val();
		$.get('compare_results', {
			q: query, start: 0, image: image, side: '1', mode: 'compare', sort: sort, lang: lang
		},
		function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	
	function setValue(field, sort_order, id) {
		var category;
		if (field.indexOf('_') > 0 || field == 'timestamp') {
			category = field;
		} else {
			if (sort_order == 'asc') {
				switch (field) {
					case 'year':
					category = field + '_minint';
					break;
					default:
					category = field + '_min';
				}
			} else if (sort_order == 'desc') {
				switch (field) {
					case 'year':
					category = field + '_maxint';
					break;
					default:
					category = field + '_max';
				}
			}
		}
		if (field != 'null') {
			$('#' + id + ' .sort_button') .prop('disabled', false);
			$('#' + id + ' .sort_param') .attr('value', category + ' ' + sort_order);
		} else {
			$('#' + id + ' .sort_button') .prop('disabled', true);
		}
	}
	
	function getURLParameter(name) {
		return decodeURI(
		(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
	}
});