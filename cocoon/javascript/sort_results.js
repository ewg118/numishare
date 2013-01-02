/************************************
SORT SEARCH RESULTS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Used to generate the query for adding
the sort parameter to solr.
************************************/
$(function () {
	$('.sortForm_categories') .change(function(){
		var field = $(this).val();
		var sort_order = $('.sortForm_order').val();
		setValue(field, sort_order);
	});
	$('.sortForm_order') .change(function(){
		var field = $('.sortForm_categories').val();		
		var sort_order = $(this).val();
		setValue(field, sort_order);
	});
	
	function setValue(field, sort_order){
		var category;
		if (field.indexOf('_') > 0 || field == 'timestamp'){		
			category = field;
		} else {
			if (sort_order == 'asc'){
				switch (field){
					case 'year':
					category = field + '_minint';
					break;
					default:
					category = field + '_min';
				}
				
			} else if (sort_order == 'desc') {
				switch (field){
					case 'year':
					category = field + '_maxint';
					break;
					default:
					category = field + '_max';
				}
			}
		}
		if (field != null){
			$('#sort_button') .removeAttr('disabled');
			$('.sort_param') .attr('value', category + ' ' + sort_order);			
		}
		else {
			$('#sort_button') .attr('disabled', 'disabled');
		}
	}
});