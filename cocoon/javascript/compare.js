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
	// display error if server doesn't respond
	$("#search") .ajaxError(function (request, settings) {
		$(this) .html('<div id="error">Error requesting page/service unavailable.</div>');
	});
	
	// total options for advanced search - used for unique id's on dynamically created elements
	var total_options = 1;
	
	// the boolean (and/or) items. these are set when a new search criteria option is created
	var gate_items = {
	};
	
	// focus the text field after selecting the field to search on
	$('#searchItemTemplate_1 select') .change(function () {
		$(this) .siblings('.search_text') .focus();
	})
	// copy the base template
	
	
	function gateTypeBtnClick(btn) {
		// increment - this is really just used to created unique ids for new dom elements
		total_options++;
		
		var tpl = $('#searchItemTemplate') .clone();
		
		// reset the id
		tpl.attr('id', 'searchItemTemplate_' + total_options);
		// reset the copied item's select element id
		$(tpl) .children('select') .attr('id', 'search_option_' + total_options);
		// reset the copied item's remove button id
		$(tpl) .children('#removeBtn_1') .attr('id', 'removeBtn_' + total_options);
		
		// focus the text field after select
		$(tpl) .children('select') .change(function () {
			$(this) .siblings('input') .focus();
		});
		
		// set up the text input
		$(tpl) .children('input') .each(function () {
			$(this) .attr('value', '');
			$(this) .attr('id', 'search_text_' + total_options);
		});
		
		// assign the handler for all gateTypeBtn elements within the new item/template
		$(tpl) .children('.gateTypeBtn') .click(function () {
			gateTypeBtnClick($(this));
		});
		
		// store in a "lookup" object
		gate_items[total_options] = btn.text();
		
		// add the new template to the dom
		$(btn) .parent() .after(tpl);
		
		// display the entire new template
		tpl.fadeIn('slow');
		
		// re-adjust the footer (footer is absolutely positioned)
		$('#footer') .css('top', $('#advancedSearchForm') .height() + 'px');
		
		// text style the remove part of the new template
		$('#removeBtn_' + total_options) .before(' |&nbsp;');
		
		// make the remove button visible
		$('#removeBtn_' + total_options) .css('visibility', 'visible');
		// assign the remove button click handler
		$('#removeBtn_' + total_options) .click(function () {
			var id = $(this) .attr('id');
			var num = id.substring(id.indexOf('_') + 1);
			// remove the gate/boolean item so the query is still valid
			delete gate_items[num];
			// fade out the entire template
			$(this) .parent() .fadeOut('slow', function () {
				$(this) .remove();
			});
			// move the footer back up
			$('#footer') .css('top', $('#advancedSearchForm') .height() + 'px');
		});
		
	}
	
	// assign the gate/boolean button click handler
	$('.gateTypeBtn') .click(function () {
		gateTypeBtnClick($(this));
	})
	
	// activates the advanced search action
	$('.compare_button') .click(function () {
		
		var image = $('#image') .attr('value');
		
		var query1 = new Array();
		var query2 = new Array();		
		
		// loop through each ".searchItemTemplate" and build the query
		$('#dataset1 .searchItemTemplate') .each(function () {
			var val = $(this) .children('.category_list') .attr('value');
			
			if ((val != 'year_num' && val != 'weight_num' && val != 'dimensions_num')  && $(this) .children('.option_container') .children('.search_text') .attr('value').length > 0) {
				query1.push (val + ':' + $(this) .children('.option_container') .children('.search_text') .attr('value'));
			}
			else if (val == 'weight_num' &&  $(this) .children('.option_container') .children('.weight_int') .attr('value').length > 0) {
				var string = '';
				string += '(' + val;
				var weight = $(this) .children('.option_container') .children('.weight_int') .attr('value');
				var range_value = $(this) .children('.option_container') .children('.weight_range') .attr('value');
				if (range_value == 'lessequal') {
					string += ':[* TO ' + weight + ']';
				} else if (range_value == 'greaterequal') {
					string += ':[' + weight + ' TO *]';
				} else if (range_value == 'equal') {
					string += ':' + weight;
				}
				string += ')';
				query1.push(string);
			} else if (val == 'dimensions_num' && $(this) .children('.option_container') .children('.dimensions_int') .attr('value').length > 0) {
				var string = '';
				string += '(' + val;
				var dimensions = $(this) .children('.option_container') .children('.dimensions_int') .attr('value');
				var range_value = $(this) .children('.option_container') .children('.dimensions_range') .attr('value');
				if (range_value == 'lessequal') {
					string += ':[* TO ' + dimensions + ']';
				} else if (range_value == 'greaterequal') {
					string += ':[' + dimensions + ' TO *]';
				} else if (range_value == 'equal') {
					string += ':' + dimensions;
				}
				string += ')';
				query1.push(string);
			} else if (val == 'year_num' && ($(this) .children('.option_container') .children('.from_date') .attr('value').length > 0 || $(this) .children('.option_container') .children('.to_date') .attr('value').length > 0)) {
				var string = '';
				string += val + ':';
				var from_date = $(this) .children('.option_container') .children('.from_date') .attr('value').length > 0 ? $(this) .children('.option_container') .children('.from_date') .attr('value') : '*';
				var from_era = $(this) .children('.option_container') .children('.from_era') .attr('value') == 'minus' ? '-' : '';
				
				var to_date = $(this) .children('.option_container') .children('.to_date') .attr('value').length > 0 ? $(this) .children('.option_container') .children('.to_date') .attr('value') : '*';
				var to_era = $(this) .children('.option_container') .children('.to_era') .attr('value') == 'minus' ? '-' : '';
				
				string += '[' + (from_date == '*' ? '' : from_era) + from_date + ' TO ' + (to_date == '*' ? '' : to_era) + to_date + ']';
				query1.push(string);
			}
	
		});
		// pass the query to the search_results url passing the needed url params:
		var query1_string = query1.length == 0 ? '*:*' : query1.join(' AND ');
		$.get('compare_results', {
			q : query1_string, start:0, image:image,  side:'1', mode: 'compare'
		}, function (data) {
			//$('#error').html('');
			// push the result into the document
			$('#search1') .html(data);
			// hide the load indicator
		});
		
		//grabbing the data from the second dataset		
		$('#dataset2 .searchItemTemplate') .each(function () {	
			var val = $(this) .children('.category_list') .attr('value');
		
			if ((val != 'year_num' && val != 'weight_num' && val != 'dimensions_num')  && $(this) .children('.option_container') .children('.search_text') .attr('value').length > 0) {
				query2.push (val + ':' + $(this) .children('.option_container') .children('.search_text') .attr('value'));
			}
			else if (val == 'weight_num' &&  $(this) .children('.option_container') .children('.weight_int') .attr('value').length > 0) {
				var string = '';
				string += '(' + val;
				var weight = $(this) .children('.option_container') .children('.weight_int') .attr('value');
				var range_value = $(this) .children('.option_container') .children('.weight_range') .attr('value');
				if (range_value == 'lessequal') {
					string += ':[* TO ' + weight + ']';
				} else if (range_value == 'greaterequal') {
					string += ':[' + weight + ' TO *]';
				} else if (range_value == 'equal') {
					string += ':' + weight;
				}
				string += ')';
				query2.push(string);
			} else if (val == 'dimensions_num' && $(this) .children('.option_container') .children('.dimensions_int') .attr('value').length > 0) {
				var string = '';
				string += '(' + val;
				var dimensions = $(this) .children('.option_container') .children('.dimensions_int') .attr('value');
				var range_value = $(this) .children('.option_container') .children('.dimensions_range') .attr('value');
				if (range_value == 'lessequal') {
					string += ':[* TO ' + dimensions + ']';
				} else if (range_value == 'greaterequal') {
					string += ':[' + dimensions + ' TO *]';
				} else if (range_value == 'equal') {
					string += ':' + dimensions;
				}
				string += ')';
				query2.push(string);
			} else if (val == 'year_num' && ($(this) .children('.option_container') .children('.from_date') .attr('value').length > 0 || $(this) .children('.option_container') .children('.to_date') .attr('value').length > 0)) {
				var string = '';
				string += val + ':';
				var from_date = $(this) .children('.option_container') .children('.from_date') .attr('value').length > 0 ? $(this) .children('.option_container') .children('.from_date') .attr('value') : '*';
				var from_era = $(this) .children('.option_container') .children('.from_era') .attr('value') == 'minus' ? '-' : '';
				
				var to_date = $(this) .children('.option_container') .children('.to_date') .attr('value').length > 0 ? $(this) .children('.option_container') .children('.to_date') .attr('value') : '*';
				var to_era = $(this) .children('.option_container') .children('.to_era') .attr('value') == 'minus' ? '-' : '';
				
				string += '[' + (from_date == '*' ? '' : from_era) + from_date + ' TO ' + (to_date == '*' ? '' : to_era) + to_date + ']';
				query2.push(string);
			}
		});
		
		// pass the query to the search_results url passing the needed url params:
		var query2_string = query2.length == 0 ? '*:*' : query2.join(' AND ');	
		$.get('compare_results', {
			q :query2_string, start:0, image:image, side:'2', mode: 'compare'
		}, function (data) {
			//$('#error').html('');
			// push the result into the document
			$('#search2') .html(data);
			// hide the load indicator
		});
		// cancel the default action of the submit buttton (don't want to re-direct)
	});
});