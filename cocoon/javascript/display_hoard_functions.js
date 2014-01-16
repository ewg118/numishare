/************************************
COMPARE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
************************************/
$(document).ready(function () {
	 $("#quantTabs").tabs();
	
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
	
	//initialize timemap
	var id = $('title').attr('id');
	
	initialize_timemap(id);
	
	//enable basic query form
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
			eventIconPath: "../images/timemap/"
		},
		datasets:[ {
			title: "Mints",
			//theme: "red",
			type: "json", // Data to be loaded in KML - must be a local URL
			options: {
				url: "../apis/get?id=" + id + "&format=json&lang=" + lang// KML file to load
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