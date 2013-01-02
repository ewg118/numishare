/************************************
COMPARE SECTION, BACK TO RESULTS
Written by Ethan Gruber, ewg4x@virginia.edu
Library: jQuery
Description: Since the compare section is heavily ajax-driven,
this allows one to go back to the search results from a record.
************************************/
$(function () {
	$(' #search1 .back_results') .click(function () {
		var href = $(this) .attr('href');
		$.get(href, {
		}, function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search2 .back_results') .click(function () {
		var href =  $(this) .attr('href');
		$.get(href, {
		}, function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
});