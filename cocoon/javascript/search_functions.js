/************************************
SEARCH FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Functions used for search and compare.
************************************/
// assign the gate/boolean button click handler
$('.gateTypeBtn') .livequery('click', function(event){
	gateTypeBtnClick($(this));
	return false;
});

// focus the text field after selecting the field to search on
$('.searchItemTemplate select').livequery('change', function(event){
	$(this) .siblings('.search_text') .focus();
});

$('.removeBtn').livequery('click', function(event){
	// fade out the entire template
	$(this) .parent() .fadeOut('fast', function () {
		$(this) .remove();
	});
	return false;
});

$('.category_list') .livequery('change', function(event){
	var field = $(this) .children("option:selected") .val();
	
	//TEXT FIELDS
	if (field.indexOf('text') > 0 || field.indexOf('display') > 0) {
		if ($(this) .parent() .children('.option_container') .children('input') .attr('class') != 'search_text') {
			$(this) .parent() .children('.option_container') .html('');
			$(this) .parent() .children('.option_container') .html('<input type="text" id="search_text" class="search_text"/>');
		}
	}
	//YEAR
	else if (field == 'year_num' || field == 'taq_num' || field == 'tpq_num') {
		$(this) .parent() .children('.option_container') .html('From: <input type="text" class="from_date"/>' +
		'<select class="from_era"><option value="minus">B.C.</option><option value="" selected="selected">A.D.</option></select>' +
		'To: <input type="text" class="to_date"/>' +
		'<select class="to_era"><option value="minus">B.C.</option><option value="" selected="selected">A.D.</option></select>');
	}
	//WEIGHT
	else if (field == 'weight_num') {
		$(this) .parent() .children('.option_container') .html('<select class="weight_range">' +
		'<option value="lessequal">Less/Equal to</option><option value="equal">Equal to</option><option value="greaterequal">Greater/Equal to</option>' +
		'</select><input type="text" class="weight_int"/> grams');
	}
	//DIMENSIONS
	else if (field == 'diameter_num') {
		$(this) .parent() .children('.option_container') .html('<select class="dimensions_range">' +
		'<option value="lessequal">Less/Equal to</option><option value="equal">Equal to</option><option value="greaterequal">Greater/Equal to</option>' +
		'</select><input type="text" class="dimensions_int"/> mm');
	}
	//SELECTING OTHER DROP DOWN MENUS SECTION
	else {	
		var query = assembleQuery('advancedSearchForm');
		var container = $(this) .parent('.searchItemTemplate') .children('.option_container');
		container.html('<img style="margin-left:100px;margin-right:100px;" src="images/ajax-loader.gif"/>');		
		var q = query + ' AND ' + field + ':[* TO *]';
		$.get('get_search_facets', {
			q : q, category:field
		}, function (data) {		
			container.html(data);
		});				
	}
});

// copy the base template
function gateTypeBtnClick(btn) {
	//clone the template
	var tpl = cloneTemplate();
	
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

function cloneTemplate (){
	var tpl = $('#searchItemTemplate') .clone();
	
	//remove id to avoid duplication with the template
	tpl.removeAttr('id');
	
	return tpl;
}

// activates the advanced search action
function assembleQuery(formId){
	var query = new Array();
	// loop through each ".searchItemTemplate" and build the query
	$('#' + formId + ' .searchItemTemplate') .each(function () {
		var field = $(this) .children('.category_list') .val();
		
		if ((field != 'year_num' && field != 'weight_num' && field != 'diameter_num' && field != 'taq_num' && field != 'tpq_num') && $(this) .children('.option_container') .children('.search_text') .val().length > 0) {
			query.push (field + ':' + $(this) .children('.option_container') .children('.search_text') .val());
		} else if (field == 'weight_num' &&  $(this) .children('.option_container') .children('.weight_int') .val().length > 0) {
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
			var from_date = $(this) .children('.option_container') .children('.from_date') .val().length > 0 ? $(this) .children('.option_container') .children('.from_date') .val() : '*';
			var from_era = $(this) .children('.option_container') .children('.from_era') .val() == 'minus' ? '-' : '';
			
			var to_date = $(this) .children('.option_container') .children('.to_date') .val().length > 0 ? $(this) .children('.option_container') .children('.to_date') .val() : '*';
			var to_era = $(this) .children('.option_container') .children('.to_era') .val() == 'minus' ? '-' : '';
			
			string += '[' + (from_date == '*' ? '' : from_era) + from_date + ' TO ' + (to_date == '*' ? '' : to_era) + to_date + ']';
			query.push(string);
		}
	});
	
	// pass the query to the search_results url passing the needed url params:
	if (query.length == 0){
		var q = '*:*';
	} else {
		var q = query.join(' AND ');
	}
	
	return q;	
}