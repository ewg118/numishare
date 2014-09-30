/************************************
COMPARE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
************************************/
$(document).ready(function () {
	$('.toggle-coin').click(function () {
		var id = $(this).attr('id').split('-')[0];
		$('#' + id + '-div').toggle('slow');
		if ($(this).text() == '[more]') {
			$(this).text('[less]');
		} else {
			$(this).text('[more]');
		}
		return false;
	});
	
	var calculate = getURLParameter('calculate');
	if (calculate != 'null') {
		$('#tabs a[href="#quantitative"]').tab('show');
		if (calculate == 'date') {
			$('#quant-tabs a[href="#dateTab"]').tab('show');
		}
	}
	
	//initialize timemap
	var id = $('title').attr('id');	
	initialize_timemap(id);
});

function initialize_timemap(id) {
	var langStr = getURLParameter('lang');
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	var tm;
	tm = TimeMap.init({
		mapId: "map", // Id of map div element (required)
		timelineId: "timeline", // Id of timeline div element (required)
		options: {
			eventIconPath: $('#include_path').text() + "/images/timemap/"
		},
		datasets:[ {
			title: "Mints",
			type: "json", 
			options: {
				url: "../apis/get?id=" + id + "&format=json&lang=" + lang
			}
		}],
		bandIntervals:[
		Timeline.DateTime.DECADE,
		Timeline.DateTime.CENTURY]
	});
}

function getURLParameter(name) {
	return decodeURI(
	(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
}