/************************************
TOGGLE COMPARE OPTIONS
Written by Ethan Gruber, ewg4x@virginia.edu
Library: jQuery
Description: This javascript file handles the dynamic search form
in the compare page.  Some fields require
text boxes, some require the entry of integers to search a range,
and the remaining query solr and return unique facets and write
them to the drop-down menu.
************************************/

$(document) .ready(toggle_options);

function toggle_options() {
	
	$('.category_list') .change(function(){
		var parentid = '#' + $(this) .parent() .attr('id');
		var dataset = '#' + $(this) .parent() .parent() .attr('id');
	
		var selected_id = $(this) .children("option:selected") .attr('id');
		if (selected_id == 'keyword_option' || selected_id == 'persname_option' || selected_id == 'geogname_option' || selected_id == 'deity_option' || selected_id == 'legend_option' || selected_id == 'iconography_option' || selected_id == 'subject_option' || selected_id == 'identifier_option') {
			if ($(this) .parent('.searchItemTemplate') .children('.option_container') .children('input') .attr('class') != 'search_text') {
				$(this) .parent('.searchItemTemplate') .children('.option_container') .html('');
				$(this) .parent('.searchItemTemplate') .children('.option_container') .html('<input type="text" id="search_text" class="search_text"/>');
			}
		}
		//YEAR
		else if (selected_id == 'year_option') {
			$(this) .parent('.searchItemTemplate') .children('.option_container') .html('<select class="year_range">' +
			'<option value="less">Before</option>' +
			'<option value="equal" selected="selected">Exactly</option>' +
			'<option value="greater">After</option></select><input type="text" class="year_int"/>' +
			'<select class="year_era"><option value="minus">B.C.</option><option value="" selected="selected">A.D.</option></select>');
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
		}
		else {
			var category = $(this) .children("option:selected") .attr('value');
			$(this) .parent('.searchItemTemplate') .children('.option_container') .html('<img style="margin-left:100px;margin-right:100px;" src="images/ajax-loader.gif"/>');
			$.get('get_search_facets', {
				q : category + ':[* TO *]', category: category
			}, function (data) {
				$(dataset) .children(parentid) .children ('.option_container') .html(data);
			});				
		}
	});
};