/* generic result page functions:
combines hard-coded fancybox call from XSLT, condenses sort_results and quick_search JS into single file
*/
$(document).ready(function () {
	$('a.thumbImage').fancybox({
		type: 'image',
		beforeShow: function () {
			this.title = '<a href="' + this.element.attr('id') + '">' + this.element.attr('title') + '</a>'
		},
		helpers: {
			title: {
				type: 'inside'
			}
		}
	});
	
	$('.sortForm_categories') .change(function () {
		var field = $(this).val();
		var sort_order = $('.sortForm_order').val();
		setValue(field, sort_order);
	});
	$('.sortForm_order') .change(function () {
		var field = $('.sortForm_categories').val();
		var sort_order = $(this).val();
		setValue(field, sort_order);
	});
	
	function setValue(field, sort_order) {
		var category;
		if (field.indexOf('_') > 0 || field == 'timestamp' || field == 'recordId') {
			category = field;
		} else {
			if (sort_order == 'asc') {
				switch (field) {
					case 'year':
					category = field + '_minint';
					break;
					case 'axis':
					case 'diameter':
					case 'taq':
					case 'tpq':					
					case 'weight':
					category = field + '_num';
					break;
					default:
					category = field + '_min';
				}
			} else if (sort_order == 'desc') {
				switch (field) {
					case 'year':
					category = field + '_maxint';
					break;
					case 'axis':
					case 'diameter':
					case 'taq':
					case 'tpq':					
					case 'weight':
					category = field + '_num';
					break;
					default:
					category = field + '_max';
				}
			}
		}
		if (field != 'null') {
			$('.sort_button') .prop('disabled', false);
			$('.sort_param') .attr('value', category + ' ' + sort_order);
		} else {
			$('.sort_button') .prop('disabled', true);
		}
	}
	
	//toggle symbol div
	$('#toggle-symbols').click(function(){
		if ($(this).children('span').hasClass('glyphicon-triangle-bottom')) {
			$(this).children('span').removeClass('glyphicon-triangle-bottom');
			$(this).children('span').addClass('glyphicon-triangle-right');
		} else {
			$(this).children('span').removeClass('glyphicon-triangle-right');
			$(this).children('span').addClass('glyphicon-triangle-bottom');
		}
		$('#symbol-container').toggle('fast');
		return false;		
	});
	
	$('#qs_form').submit(function () {
		assembleQuery();
	});
	
	function assembleQuery() {
		var search_text = $('#qs_text') .val();
		var query = $('#qs_query').val();
		if (search_text != null && search_text != '') {
			if (query == '*:*' || query.length == 0) {
				$('#qs_query') .attr('value', 'fulltext:' + search_text);
			} else {
				$('#qs_query') .attr('value', query + ' AND fulltext:' + search_text);
			}
		} else {
			$('#qs_query') .attr('value', '*:*');
		}
	}
});