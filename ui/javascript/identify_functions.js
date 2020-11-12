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
			materials.push('material_facet:"' + $(this).val() + '"');
		});
		
		//portraits
		var portraits = new Array();
		$('input[field=portrait]:checked').each(function () {
			portraits.push('portrait_facet:"' + $(this).val() + '"');
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
				frags.push(materials[0]);
			} else {
				frags.push('(' + materials.join(' OR ') + ')');
			}
		}
		
		//add portraits
		if (portraits.length > 0) {
			if (portraits.length == 1) {
				frags.push(portraits[0]);
			} else {
				frags.push('(' + portraits.join(' OR ') + ')');
			}
		}
		
		query = frags.join(' AND ');
		$('#q_input').attr('value', query);
	});
	
	//on checking a material box, iterate through each portrait to show the coin of that metal, if avaiable
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
	
	//pagination functions. display next or previous image
	$('.page-next').click(function () {
		var bg = $(this).closest('div.portrait').children('.image-spacer').children('img').attr('src');
		
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
					$(this).closest('div.portrait').children('.image-spacer').children('img').attr('src', list[0]);
				} else {					
					$(this).closest('div.portrait').children('.image-spacer').children('img').attr('src', list[i+1]);
				}
			}
		}
		return false;
	});
	
	$('.page-prev').click(function () {
		var bg = $(this).closest('div.portrait').children('.image-spacer').children('img').attr('src');
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
				    $(this).closest('div.portrait').children('.image-spacer').children('img').attr('src',list[list.length - 1]);
				} else {	
                    $(this).closest('div.portrait').children('.image-spacer').children('img').attr('src', list[i-1]);
				}
			}
		}
		return false;
	});
	
	//check or uncheck the box if the image is clicked
	$('.image-spacer').click(function(){
	       var checkbox = $(this).next('.paginate-images').find('input[type=checkbox]');
	       if (checkbox.is(':checked')) {
	           checkbox.prop('checked', false);
	       } else {
	           checkbox.prop('checked', true);
	       }
	});
});

function renderPortraits(material) {
	$('.portrait').each(function () {
		var obj = jQuery.parseJSON($(this).children('div[class=hidden]').text());
		if (material in obj) {
			var url = obj[material][0];
			$(this).children('.image-spacer').children('img').attr('src',url);			
		}
	});
}