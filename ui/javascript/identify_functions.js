/************************************
IDENTIFY FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Functions used for for the identify coin type page
 ************************************/
// assign the gate/boolean button click handler
$(document).ready(function () {
	$('#identify-form').submit(function () {
		//query fragments
		var frags = new Array();
		
		//materials
		var materials = new Array();
		$('input[field=material]:checked').each(function () {
			materials.push('"' + $(this).val() + '"');
		});
		
		//portraits
		var portraits = new Array();
		$('input[field=portrait]:checked').each(function () {
			portraits.push('"' + $(this).val() + '"');
		});
		
		//add legends if applicable
		if ($('input[field=obv_leg_text]').val().length > 0) {
			frags.push('obv_legendCondensed_text:' + $('input[field=obv_leg_text]').val());
		}
		if ($('input[field=rev_leg_text]').val().length > 0) {
			frags.push('rev_legendCondensed_text:' + $('input[field=rev_leg_text]').val());
		}
		
		//add materials
		if (materials.length > 0) {
			if (materials.length == 1) {
				frags.push('material_facet:' + materials[0]);
			} else {
				frags.push('material_facet:(' + materials.join(' OR ') + ')');
			}
		}
		
		//add portraits
		if (portraits.length > 0) {
			if (portraits.length == 1) {
				frags.push('portrait_facet:' + portraits[0]);
			} else {
				frags.push('portrait_facet:(' + portraits.join(' OR ') + ')');
			}
		}
		
		query = frags.join(' AND ');
		$('#q_input').attr('value', query);
	});
	
	
	$('input[field=material]').click(function () {
		if ($(this).is(':checked')) {
			var material = $(this).attr('id').split('-')[1];
			renderPortraits(material);
		} else {
			//on unchecking, evaluate if there are still checked boxes and render the first one
			if ($('input[field=material]:checked').length > 0) {
				var material = $('input[field=material]:checked:first').attr('id').split('-')[1];
				renderPortraits(material);
			}
		}
	});
	
	$('.page-next').click(function () {
		var bg = $(this).closest('div.portrait').css('background-image').match(/url\(["|']?([^"']*)["|']?\)/)[1];
		var obj = jQuery.parseJSON($(this).closest('div.portrait').children('div[class=hidden]').text());
		var list = new Array();
		for (var material in obj) {
			for (index in obj[material]) {
				//add URL to array
				list.push(obj[material][index]);
			}
		}
		
		for (i in list) {
			i = parseInt(i);
			if (list[i] == bg) {
				//if the image is last
				if ((i + 1) == list.length) {
					$(this).closest('div.portrait').css({
						'background': 'url(' + list[0] + ')',
						'background-size': '100%',
						'background-repeat': 'no-repeat'
					});
				} else {					
					$(this).closest('div.portrait').css({
						'background': 'url(' + list[i+1] + ')',
						'background-size': '100%',
						'background-repeat': 'no-repeat'
					});
				}
			}
		}
		return false;
	});
	
	$('.page-prev').click(function () {
		var bg = $(this).closest('div.portrait').css('background-image').match(/url\(["|']?([^"']*)["|']?\)/)[1];
		var obj = jQuery.parseJSON($(this).closest('div.portrait').children('div[class=hidden]').text());
		var list = new Array();
		for (var material in obj) {
			for (index in obj[material]) {
				//add URL to array
				list.push(obj[material][index]);
			}
		}
		
		for (i in list) {
			i = parseInt(i);
			if (list[i] == bg) {
				//if the image is last
				if (i == 0) {
					$(this).closest('div.portrait').css({
						'background': 'url(' + list[list.length - 1] + ')',
						'background-size': '100%',
						'background-repeat': 'no-repeat'
					});
				} else {					
					$(this).closest('div.portrait').css({
						'background': 'url(' + list[i-1] + ')',
						'background-size': '100%',
						'background-repeat': 'no-repeat'
					});
				}
			}
		}
		return false;
	});
});

function renderPortraits(material) {
	$('.portrait').each(function () {
		var obj = jQuery.parseJSON($(this).children('div[class=hidden]').text());
		if (material in obj) {
			var url = obj[material][0];
			$(this).css({
				'background': 'url(' + url + ')',
				'background-size': '100%',
				'background-repeat': 'no-repeat'
			});
		}
	});
}