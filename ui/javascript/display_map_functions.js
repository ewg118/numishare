$(document).ready(function () {
	var id = $('title').attr('id');
	var collection_type = $('#collection_type').text();
	var path = $('#path').text();
	var pipeline = $('#pipeline').text();
	var langStr = getURLParameter('lang');
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	init();
	
	function init() {
		if (collection_type != 'object') {
			if ($('#map').html().length == 0) {
				initialize_timemap(id, path, lang);
			}
		} else {
			if ($('#mapcontainer').html().length == 0) {
				initialize_map(id, path, lang);
			}
		}
	}
});

function initialize_timemap(id, path, lang) {
	var url = path + "apis/get?id=" + id + "&format=json&lang=" + lang;
	var datasets = new Array();
	
	//first dataset
	datasets.push({
		id: 'dist',
		title: "Distribution",
		type: "json",
		options: {
			url: url
		}
	});
	
	var tm;
	tm = TimeMap.init({
		mapId: "map", // Id of map div element (required)
		timelineId: "timeline", // Id of timeline div element (required)
		options: {
			mapType: "physical",
			eventIconPath: $('#include_path').text() + "/images/timemap/"
		},
		datasets: datasets,
		bandIntervals:[
		Timeline.DateTime.YEAR,
		Timeline.DateTime.DECADE]
	});
	function toggleDataset(dsid, toggle) {
		if (toggle) {
			tm.datasets[dsid].show();
		} else {
			tm.datasets[dsid].hide();
		}
	}
}

function initialize_map(id, path, lang) {
	var baselayers = $('#baselayers').text().split(',');
	var mapboxKey = $('#mapboxKey').text();
	var url = path + id + ".geojson" + (lang.length > 0 ? '?lang=' + lang: '');
	
	//baselayers
	var osm = L.tileLayer(
	'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
		attribution: 'OpenStreetMap',
		maxZoom: 10
	});
	
	var imperium = L.tileLayer(
	'http://dare.ht.lu.se/tiles/imperium/{z}/{x}/{y}.png', {
		maxZoom: 10,
		attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a>. Map base: <a href="http://dare.ht.lu.se/" title="Digital Atlas of the Roman Empire, Department of Archaeology and Ancient History, Lund University, Sweden">DARE</a>, 2015 (cc-by-sa).'
	});
	var mb_physical = L.tileLayer(
	'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=' + mapboxKey, {
		attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
		'<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
		'Imagery © <a href="http://mapbox.com">Mapbox</a>', id: 'mapbox.streets', maxZoom: 10
	});
	
	var map = new L.Map('mapcontainer', {
		center: new L.LatLng(0, 0),
		zoom: 4,
		layers:[eval(baselayers[0])]
	});
	
	//add mintLayer from AJAX
	var overlay = L.geoJson.ajax(url, {
		onEachFeature: onEachFeature,
		pointToLayer: renderPoints
	}).addTo(map);
	
	//add controls
	var baseMaps = {
	};
	//add baselayers
	var i;
	for (i = 0; i < baselayers.length; i++) {
		var label;
		switch (baselayers[i]) {
			case 'osm': label = "OpenStreetMap";
			break;
			case 'imperium': label = 'Imperium Romanum';
			break;
			case 'mb_physical': label = 'Terrain and Streets';
			break;
		}
		baseMaps[label] = eval(baselayers[i]);
	}
	
	var overlayMaps = {
		'Markers': overlay
	};
	
	//add controls
	var layerControl = L.control.layers(baseMaps, overlayMaps).addTo(map);
	
	//zoom to groups on AJAX complete
	overlay.on('data:loaded', function () {
		map.fitBounds(overlay.getBounds());
	}.bind(this));
	
	/*****
	 * Features for manipulating layers
	 *****/
	function renderPoints(feature, latlng) {
		var fillColor;
		switch (feature.properties.type) {
			case 'mint':
			fillColor = '#6992fd';
			break;
			case 'findspot':
			fillColor = '#d86458';
			break;
			case 'subject':
			fillColor = '#a1d490';
		}
		
		return new L.CircleMarker(latlng, {
			radius: 5,
			fillColor: fillColor,
			color: "#000",
			weight: 1,
			opacity: 1,
			fillOpacity: 0.6
		});
	}
	
	function onEachFeature (feature, layer) {
		var label = feature.properties.name;
		str = label + ' <a href="' + feature.properties.uri + '" target="_blank"><span class="glyphicon glyphicon-new-window"/></a>';
		layer.bindPopup(str);
	}
}

function getURLParameter(name) {
	return decodeURI(
	(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
}