/************************************
SEARCH FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Functions used for search and compare.
************************************/
// assign the gate/boolean button click handler
$(document).ready(function () {
	var langStr = getURLParameter('lang');
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	var path = $('#display_path').text();
	var pipeline = $('#pipeline').text();
	
	function getURLParameter(name) {
		return decodeURI(
		(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
	}
	
	/***** TOGGLING FACET FORM*****/
	$('.inputContainer') .on('click', '.searchItemTemplate .gateTypeBtn', function () {
		gateTypeBtnClick($(this));
		//disable date select option if there is already a date select option
		if ($(this).closest('form').attr('id') == 'sparqlForm') {
			var count = countDate();
			if (count == 1) {
				$('#sparqlForm .searchItemTemplate').each(function () {
					//disable all new searchItemTemplates which are not already set to date
					if ($(this).children('.sparql_facets').val() != 'date') {
						$(this).find('option[value=date]').attr('disabled', true);
					}
				});
			}
		}
		
		return false;
	});
	$('.inputContainer').on('click', '.searchItemTemplate .removeBtn', function () {
		//enable date option in sparql form if the date is being removed
		if ($(this).closest('form').attr('id') == 'sparqlForm') {
			$('#sparqlForm .searchItemTemplate').each(function () {
				$(this).find('option[value=date]').attr('disabled', false);
				//enable submit
				$('#sparqlForm input[type=submit]').attr('disabled', false);
				//hide error
				$('#sparqlForm-alert').hide();
			});
		}
		
		// fade out the entire template
		$(this) .parent() .fadeOut('fast', function () {
			$(this) .remove();
		});
		return false;
	});
	
	$('.inputContainer').on('change', '.searchItemTemplate .category_list', function () {
		var field = $(this) .children("option:selected") .val();
		if (field.indexOf('text') > 0 || field.indexOf('display') > 0 || field=='recordId' || field=='typeNumber') {
			if ($(this) .parent() .children('.option_container') .children('input') .attr('class') != 'search_text') {
				$(this) .parent() .children('.option_container') .html('');
				$(this) .parent() .children('.option_container') .html('<input type="text" id="search_text" class="search_text form-control"/>');
			}
		} else if (field == 'year_num' || field == 'taq_num' || field == 'tpq_num') {
			$(this) .parent() .children('.option_container') .html('From: <input type="text" class="from_date form-control"/>' +
			'<select class="from_era form-control"><option value="minus">B.C.</option><option value="" selected="selected">A.D.</option></select>' +
			'To: <input type="text" class="to_date form-control"/>' +
			'<select class="to_era form-control"><option value="minus">B.C.</option><option value="" selected="selected">A.D.</option></select>');
		} else if (field == 'weight_num') {
			$(this) .parent() .children('.option_container') .html('<select class="weight_range form-control">' +
			'<option value="lessequal">Less/Equal to</option><option value="equal">Equal to</option><option value="greaterequal">Greater/Equal to</option>' +
			'</select><input type="text" class="weight_int form-control"/> grams');
		} else if (field == 'diameter_num') {
			$(this) .parent() .children('.option_container') .html('<select class="dimensions_range form-control">' +
			'<option value="lessequal">Less/Equal to</option><option value="equal">Equal to</option><option value="greaterequal">Greater/Equal to</option>' +
			'</select><input type="text" class="dimensions_int form-control"/> mm');
		} else {
			var container = $(this) .parent('.searchItemTemplate') .children('.option_container');
			var query = assembleQuery('advancedSearchForm');
			var q = query + ' AND ' + field + ':[* TO *]';
			$.get(path + 'get_search_facets', {
				q: q, category: field, lang: lang, pipeline: pipeline
			},
			function (data) {
				container.html(data);
			});
		}
	});
});

// copy the base template
function gateTypeBtnClick(btn) {
	var formId = btn.closest('form').attr('id');
	
	//clone the template
	var tpl = cloneTemplate(formId);
	
	// focus the text field after select
	$(tpl) .children('select') .change(function () {
		$(this) .siblings('input') .focus();
	});
	
	// add the new template to the dom
	$(btn) .parent() .after(tpl);
	
	tpl.children('.removeBtn').removeAttr('style');
	tpl.children('.removeBtn') .before(' |&nbsp;');
	
	// display the entire new template
	tpl.fadeIn('fast');
}

function cloneTemplate(formId) {
	if (formId == 'sparqlForm') {
		var tpl = $('#sparqlItemTemplate') .clone();
	} else {
		var tpl = $('#searchItemTemplate') .clone();
	}
	
	//remove id to avoid duplication with the template
	tpl.removeAttr('id');
	
	return tpl;
}

// activates the advanced search action
function assembleQuery(formId) {
	var query = new Array();
	// loop through each ".searchItemTemplate" and build the query
	$('#' + formId + ' .searchItemTemplate') .each(function () {
		var field = $(this) .children('.category_list') .val();
		if (field != 'year_num' && field != 'weight_num' && field != 'diameter_num' && field != 'taq_num' && field != 'tpq_num') {
			var val = $(this) .children('.option_container') .children('.search_text') .val();
			if (val != null && val.length > 0) {
				query.push(field + ':' + val);
			}
		} else if (field == 'weight_num' && $(this) .children('.option_container') .children('.weight_int') .val().length > 0) {
			var string = '';
			string += '(' + field;
			var weight = $(this) .children('.option_container') .children('.weight_int') .val();
			var range_value = $(this) .children('.option_container') .children('.weight_range') .val();
			if (range_value == 'lessequal') {
				string += ':[* TO ' + weight + ']';
			} else if (range_value == 'greaterequal') {
				string += ':[' + weight + ' TO *]';
			} else if (range_value == 'equal') {
				string += ':' + weight;
			}
			string += ')';
			query.push(string);
		} else if (field == 'diameter_num' && $(this) .children('.option_container') .children('.dimensions_int') .val().length > 0) {
			var string = '';
			string += '(' + field;
			var dimensions = $(this) .children('.option_container') .children('.dimensions_int') .val();
			var range_value = $(this) .children('.option_container') .children('.dimensions_range') .val();
			if (range_value == 'lessequal') {
				string += ':[* TO ' + dimensions + ']';
			} else if (range_value == 'greaterequal') {
				string += ':[' + dimensions + ' TO *]';
			} else if (range_value == 'equal') {
				string += ':' + dimensions;
			}
			string += ')';
			query.push(string);
		} else if ((field == 'year_num' || field == 'taq_num' || field == 'tpq_num') && ($(this) .children('.option_container') .children('.from_date') .val().length > 0 || $(this) .children('.option_container') .children('.to_date') .val().length > 0)) {
			var string = '';
			string += field + ':';
			var from_date = $(this) .children('.option_container') .children('.from_date') .val().length > 0? $(this) .children('.option_container') .children('.from_date') .val(): '*';
			var from_era = $(this) .children('.option_container') .children('.from_era') .val() == 'minus'? '-': '';
			
			var to_date = $(this) .children('.option_container') .children('.to_date') .val().length > 0? $(this) .children('.option_container') .children('.to_date') .val(): '*';
			var to_era = $(this) .children('.option_container') .children('.to_era') .val() == 'minus'? '-': '';
			
			string += '[' + (from_date == '*'? '': from_era) + from_date + ' TO ' + (to_date == '*'? '': to_era) + to_date + ']';
			query.push(string);
		}
	});
	// pass the query to the search_results url passing the needed url params:
	if (query.length == 0) {
		var q = '*:*';
	} else {
		var q = query.join(' AND ');
	}
	
	return q;
}