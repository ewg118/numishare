/************************************
ASSEMBLE SOLR QUERY FOR SEARCH WIDGET
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Assemble the query to pass to the results action.
************************************/
$(document).ready(function () {

	var popupStatus = 0;
	
	$("#backgroundPopup").livequery('click', function(event) {
		disablePopup();
	});

	$(".multiselect").multiselect({		
   		//selectedList: 3,
   		minWidth:'auto',
   		header:'<a class="ui-multiselect-none" href="#"><span class="ui-icon ui-icon-closethick"/><span>Uncheck all</span></a>',
   		create: function(){
   			var title = $(this).attr('title');
   			$('button[title=' + title + ']').children('span:nth-child(2)').text(title);
   		},
   		open: function(){
	   		var title = $(this).attr('title');
      			var id = $(this) .attr('id');
      			if ($(this).html().indexOf('<option') < 0){
	      			var q = $(this).attr('q');
	      			var category = id.split('-select')[0];
	      			var mincount = $(this).attr('mincount');
	      			$.get('get_facet_options', {
					q: q, category: category, sort: 'index', limit:-1, mincount:mincount
					},
					function (data) {
						$('#' + id) .html(data);
						$("#" + id).multiselect('refresh')
						$('button[title=' + title + ']').children('span:nth-child(2)').text(title);
					});
			}
   		},
   		//close menu: restore button title if no checkboxes are selected
   		close: function(){
   			var title = $(this).attr('title');
      			var array_of_checked_values = $(this).multiselect("getChecked").map(function(){
				return this.value;
			}).get();	
			if (array_of_checked_values.length == 0){
				$('button[title=' + title + ']').children('span:nth-child(2)').text(title);
			}
   		}, 
   		click: function(){
   			var title = $(this).attr('title');
   			var array_of_checked_values = $(this).multiselect("getChecked").map(function(){
				return this.value;
			}).get();	
			var length = array_of_checked_values.length;
			if (length > 3){
				$('button[title=' + title + ']').children('span:nth-child(2)').text(title + ': ' + length + ' selected');
			} else if (length > 0 && length <= 3){
				$('button[title=' + title + ']').children('span:nth-child(2)').text(title + ': ' + array_of_checked_values.join(', '));
			} else if (length == 0){
				$('button[title=' + title + ']').children('span:nth-child(2)').text(title);
			}
   		}
	}).multiselectfilter();
	
	//hovering
	$('#category_facet_link').hover(function () {
    		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all ui-state-focus');
	}, 
	function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all');
	});	
	
	$('#search_button').hover(function () {
    		$(this) .attr('class', 'ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only ui-state-focus ui-state-hover');
	}, 
	function () {
		$(this) .attr('class', 'ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only ui-state-focus');
	});	
	
	$('.category-close') .click(function(){
		disablePopup();
	});
	
	//click on category button
	$('#category_facet_link').click(function () {
		if (popupStatus == 0) {
			$("#backgroundPopup").fadeIn("fast");
			popupStatus = 1;
		}
		var list_id = $(this) .attr('id').split('_link')[0] + '-list';
		var department = $('form').attr('title');
		if (department == 'United States'){
			$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
		} else {	
			var category = $(this) .attr('id') .split('_link')[0];
			var q = $(this) .attr('label');
			var department = $('form').attr('title');
			if ($('#' + list_id).html().indexOf('<li') < 0) {
				$.get('get_categories', {
					q: 'department_facet:"' + department + '"', category: category, prefix: 'L1', fq: '*', section: 'collection', link: ''
				},
				function (data) {
					$('#' + list_id) .html(data);
				});				
			}
			$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
		}
	});
	
	//USA categories
	$('.expand_usa_category').click(function(){
		var src = $(this).children('img').attr('src');
		if (src.indexOf('plus') > -1){
			$(this).children('img').attr('src', src.replace('plus', 'minus'));
		} else {
			$(this).children('img').attr('src', src.replace('minus', 'plus'));
		}
		$(this) .parent('.term').children('.category_level').toggle();
	});
	
	//non USA categories
	$('.expand_category') .livequery('click', function (event) {
		var fq = $(this) .attr('id').split('__')[0];
		var list = fq.split('|')[1] + '__list';
		var prefix = $(this).attr('next-prefix');
		var q = $(this) .attr('q');
		var link = $(this) .attr('link');
		var section = $(this) .attr('section');
		if ($(this) .children('img') .attr('src') .indexOf('plus') >= 0) {
			$.get('get_categories', {
				q: q, prefix: prefix, fq: '"' + fq.replace('_', ' ') + '"', link: link + ' AND category_facet:"' + fq + '"', section: section
			},
			function (data) {
				$('#' + list) .html(data);				
			});
			$(this) .parent('.term') .children('.category_level') .show();
			$(this) .children('img') .attr('src', $(this) .children('img').attr('src').replace('plus', 'minus'));
		} else {
			$(this) .parent('.term') .children('.category_level') .hide();
			$(this) .children('img') .attr('src', $(this) .children('img').attr('src').replace('minus', 'plus'));
		}
	});
	
	$('.term input') .livequery('click', function (event) {
		if ($(this) .is(':checked')) {
			$(this) .parents('.term') .children('input') .attr('checked', true);
		} else {
			$(this) .parent('.term') .children('.category_level') .find('input').attr('checked', false);
		}
		var count_checked = 0;
		$('.term input').each(function () {
   			if (this.checked) {
   				count_checked++;
   			}
		});

		if (count_checked > 0){
			category_label();
		} else {
			$('#category_facet_link').attr('title', 'Select options');
			$('#category_facet_link').children('span:nth-child(2)').html('Category');
		}
	});
	
	function category_label(){
		categories = new Array();
		$('.term') .children('input:checked') .each(function () {
			if ($(this) .parent('.term') .html() .indexOf('category_level') < 0 || $(this) .parent('.term') .children('ul') .html() .indexOf('<li') < 0 || $(this) .parent('.term') .children('.category_level').find('input:checked').length == 0) {
				segment = new Array();
				$(this) .parents('.term').each(function () {
					segment.push($(this).children('input').val().split('|')[1]);
				});
				var joined = segment.reverse().join('--');
				categories.push(joined);
				if (categories.length > 0 && categories.length <= 3){
					$('#category_facet_link').attr('title', 'Category: ' + categories.join(', '));
					$('#category_facet_link').children('span:nth-child(2)').html( 'Category: ' + categories.join(', '));					
				} else if (categories.length > 3){
					$('#category_facet_link').attr('title', 'Category: ' +  categories.length + ' selected');
					$('#category_facet_link').children('span:nth-child(2)').html( 'Category: ' + categories.length + ' selected');					
				} 
			}
		});
		
	}
	
	$('#search_button') .click(function () {		
		var department = $('form').attr('title');
		var query = 'department_facet:"' + department + '"';
		
		//get search box
		var search_text = $('#cs_text').val();
		if (search_text.length > 0){
			query += ' AND fulltext:' + search_text;
		}
		
		//get categories
		categories = new Array();
		$('.term') .children('input:checked') .each(function () {
			if ($(this) .parent('.term') .html() .indexOf('category_level') < 0 || $(this) .parent('.term') .children('ul') .html() .indexOf('<li') < 0 || $(this) .parent('.term') .children('.category_level').find('input:checked').length == 0) {
				segment = new Array();
				if (department == 'United States'){
					var top_level = '+L1|USA ';
				} else {
					var top_level='';
				}
				$(this) .parents('.term').each(function () {
					segment.push('+"' + $(this).children('input').val() + '"');
				});
				var joined = 'category_facet:(' + top_level + segment.join(' ') + ')';
				categories.push(joined);
			}
		});
		//if the categories array is not null, establish the category query string
		if (categories[0] != null) {
			if (categories.length > 1) {
				query += ' AND (' + categories.join(' OR ') + ')';
			} else {
				query += ' AND ' + categories[0];
			}
		}
		
		//get multiselects
		$('.multiselect').each(function () {
			var facet = $(this).attr('id').split('-')[0];
			segment = new Array();
			$(this) .children('option:selected').each(function () {
				if ($(this) .val() != null && $(this) .val() != ''){
					segment.push(facet + ':"' + $(this).val() + '"');
				}				
			});
			if (segment[0] != null) {
				if (segment.length > 1){
					query += ' AND (' + segment.join(' OR ') + ')';
				}
				else {
					query += ' AND ' + segment[0];
				}
			}
		});
		
		$('.select').each(function () {
			var facet = $(this).attr('id').split('-')[0];
			if ($(this) .val() != 'Any' && $(this) .val() != null && $(this) .val() != '') {
				query += ' AND ' + facet + ':"' + $(this).val() + '"';
			}
		});
		
		if ($('#imagesavailable') .is(':checked')) {
			query += ' AND imagesavailable:true';
		}

		//set the value attribute of the q param to the query assembled by javascript
		$('input[name=q]').attr('value', query);
	});
	
	
	/***************************/
	//@Author: Adrian "yEnS" Mato Gondelle
	//@website: www.yensdesign.com
	//@email: yensamg@gmail.com
	//@license: Feel free to use it, but keep this credits please!
	/***************************/
	
	//disabling popup with jQuery magic!
	function disablePopup() {
		//disables popup only if it is enabled
		if (popupStatus == 1) {	
			$("#backgroundPopup").fadeOut("fast");
			$('#category_facet-list') .parent('div').attr('style', 'width: 192px;');
			popupStatus = 0;		
		}
	}
});