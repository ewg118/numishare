/****
Author: Ethan Gruber
Date: April 2014
Function: Generic functions for hoard analysis page: handle bootstrap tabs changing
***/
$(document).ready(function () {
	
	var calculate = getURLParameter('calculate');
	if (calculate != null) {
		if (calculate == 'date') {
			$('#quant-tabs a[href="#dateTab"]').tab('show');
		}
	}
});

function getURLParameter(name) {
	return decodeURI(
	(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
}