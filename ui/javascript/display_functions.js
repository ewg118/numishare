/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
 ************************************/
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
});

// copy the base template
function gateTypeBtnClick(btn) {
	var formId = btn.closest('form').attr('id');
	
	//clone the template
	var tpl = cloneTemplate(formId);
	
	// focus the text field after select
	$(tpl).children('select').change(function () {
		$(this).siblings('input').focus();
	});
	
	// add the new template to the dom
	$(btn).parent().after(tpl);
	
	tpl.children('.removeBtn').removeAttr('style');
	tpl.children('.removeBtn').before(' |&nbsp;');
	// display the entire new template
	tpl.fadeIn('fast');
}

function cloneTemplate(formId) {
	if (formId == 'sparqlForm') {
		var tpl = $('#sparqlItemTemplate').clone();
	} else {
		var tpl = $('#searchItemTemplate').clone();
	}
	
	//remove id to avoid duplication with the template
	tpl.removeAttr('id');
	return tpl;
}