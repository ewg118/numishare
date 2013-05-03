/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
************************************/
$(document).ready(function () {
	$('a.thumbImage').fancybox();	
	$("#tabs").tabs();
	
	/***** TOGGLING FACET FORM*****/
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
	
	function cloneTemplate (formId){	
		if (formId == 'sparqlForm') {
			var tpl = $('#sparqlItemTemplate') .clone();
		} else {
			var tpl = $('#searchItemTemplate') .clone();
		}
		
		//remove id to avoid duplication with the template
		tpl.removeAttr('id');
		
		return tpl;
	}	
});