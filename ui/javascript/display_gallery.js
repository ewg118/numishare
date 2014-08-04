/************************************
MANIPULATE IMAGES IN DISPLAY SECTION
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
This is for showing the enlarge image helper div when hovering the mouse over a screen image as well as
cycling through the image gallary.
************************************/
$(function () {
	$('.reference_image') .hover(function () {
		$(this) .parent() .children('.enlarge') .fadeIn('fast');
	},
	function () {
		$(this) .parent() .children('.enlarge') .fadeOut('fast');
	});
	
	$('.reference_image') .click(function () {
		if ($('.reference_image') .attr('title') == null) {
			$('#djatoka') .attr('src', $(this) .attr('href'));
			$('#djatoka') .fadeIn('fast');
			$.scrollTo('#djatoka', {
				speed: 2000
			});
		}
	});
	
	$('.display_thumb') .click(function () {
		$('.reference_image') .hide();
		var href = $(this) .attr('id');
		var title = $(this) .attr('title');
		
		$('#reference_display') .html(title);
		
		
		
		if ($('.reference_image') .attr('title') == null) {
			/*alter link attributes*/
			$('.reference_image') .attr('title', title);
			$('.reference_image') .attr('href', href);
			/*alter image attributes*/
			$('.reference_image') .children('img') .attr('alt', 'Image: ' + title);
			$('.reference_image') .children('img') .attr('src', href);
		} else {
			$('.reference_image') .attr('alt', 'Image: ' + title);
			$('.reference_image') .attr('src', href);
		}
		
		
		
		$('.reference_image') .fadeIn(333);
	});
});