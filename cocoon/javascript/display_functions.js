/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
************************************/
$(document).ready(function () {
	$('a.thumbImage').fancybox();
	
	/***** TOGGLING FACET FORM*****/
	$('#sparqlInputContainer') .on('click', '.searchItemTemplate .gateTypeBtn', function(event){
		gateTypeBtnClick($(this));
		
		//disable date select option if there is already a date select option
		if ($(this).closest('form').attr('id') == 'sparqlForm'){
			var count = countDate();
			if (count == 1) {
				$('#sparqlForm .searchItemTemplate').each(function(){
					//disable all new searchItemTemplates which are not already set to date
					if ($(this).children('.sparql_facets').val() != 'date'){
						$(this).find('option[value=date]').attr('disabled', true);
					}
					
				});
			}
		}
		
		return false;
	});
	
	$('#sparqlInputContainer') .on('click', '.searchItemTemplate .removeBtn', function(event){
		//enable date option in sparql form if the date is being removed
		if ($(this).closest('form').attr('id') == 'sparqlForm'){
			$('#sparqlForm .searchItemTemplate').each(function(){
				$(this).find('option[value=date]').attr('disabled', false);
				//enable submit
				$('#sparqlForm input[type=submit]').attr('disabled', false);
				//hide error				
				$('#sparqlForm-alert').hide();
			});
		}
	
		// fade out the entire template
		$(this) .parent() .fadeOut('fast', function () {
			$(this) .remove();
		});
		return false;
	});
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