/************************************
COMPARE SECTION, PAGINATION AND COIN RECORD EXPANSION
Written by Ethan Gruber, ewg4x@virginia.edu
Library: jQuery
Description: Allows for pagination for each column
in the compare section and allows for the individual coin 
record to be displayed.  Ajax-driven.
************************************/
$(function () {
	$(' #search1 .comparepagingBtn') .click(function () {
		var href = $(this) .attr('href');
		$.get(href, {
		}, function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search1 .compare') .click(function () {
		$.get($(this) .attr('href'), {
		}, function (data) {
			$('#search1') .html(data);
		});
		return false;
	});
	$(' #search2 .comparepagingBtn') .click(function () {
		var href =  $(this) .attr('href');
		$.get(href, {
		}, function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
	$(' #search2 .compare') .click(function () {
		$.get($(this) .attr('href'), {
		}, function (data) {
			$('#search2') .html(data);
		});
		return false;
	});
});