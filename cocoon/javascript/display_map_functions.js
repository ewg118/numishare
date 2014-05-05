$(document).ready(function () {
	var id = $('title').attr('id');
	var collection_type = $('#collection_type').text();
	var path = $('#path').text();
	var pipeline = $('#pipeline').text();
	
	if (collection_type == 'object') {
		$('#mapButton').click(function(){
			$('#tabs a:last').tab('show');
			init();			
		});	
	} else {
		init();
	}
	//only load map upon tab click on object pages, due to bootstrap tabs glitch
	
	
	function init() {
		if (collection_type != 'object') {		
			if ($('#map').html().length == 0) {		
				initialize_timemap(id, path);
			}
		} else {
			if ($('#mapcontainer').html().length == 0) {
				initialize_map(id, path);
			}
		}
	}
});

function initialize_timemap(id, path) {
	var langStr = getURLParameter('lang');
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
	}
	
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
			eventIconPath: "../images/timemap/"
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

function initialize_map(id, path) {
	/***** DECLARE BASELAYERS ******/
	var google_physical = new OpenLayers.Layer.Google("Google Physical", {
		type: google.maps.MapTypeId.TERRAIN
	});
	var imperium = new OpenLayers.Layer.XYZ(
	"Imperium Romanum",[
	"http://pelagios.dme.ait.ac.at/tilesets/imperium/${z}/${x}/${y}.png"], {
		sphericalMercator: true,
		isBaseLayer: true,
		numZoomLevels: 12,
		attribution: '<a href="http://imperium.ahlfeldt.se">Digital Atlas of the Roman Empire</a>, hosted by <a href="http://pelagios-project.blogspot.com">Pelagios</a>.'
	});
	var osm = new OpenLayers.Layer.OSM();
	
	var baselayers = $('#baselayers').text().split(',');
	
	map = new OpenLayers.Map('mapcontainer', {
		controls:[
		new OpenLayers.Control.PanZoomBar(),
		new OpenLayers.Control.Navigation(),
		new OpenLayers.Control.ScaleLine(),
		new OpenLayers.Control.Attribution(),
		new OpenLayers.Control.LayerSwitcher({
			'ascending': true
		})]
	});
	
	//add baselayers
	var i;
	for (i = 0; i < baselayers.length; i++) {
		map.addLayer(eval(baselayers[i]));
	}
	
	//point for coin or hoard KML
	var kmlLayer = new OpenLayers.Layer.Vector($('#object_title').text(), {
		eventListeners: {
			'loadend': kmlLoaded
		},
		strategies:[
		new OpenLayers.Strategy.Fixed()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: id + '.kml',
			format: new OpenLayers.Format.KML({
				extractStyles: true,
				extractAttributes: true
			})
		})
	});
	
	//add origin point last
	map.addLayer(kmlLayer);
	
	function kmlLoaded() {
		map.zoomToExtent(kmlLayer.getDataExtent());
	}
	
	/*************** OBJECT KML FEATURES ******************/
	objectControl = new OpenLayers.Control.SelectFeature([kmlLayer], {
		clickout: true,
		multiple: false,
		hover: false,
	});
	
	map.addControl(objectControl);
	objectControl.activate();
	kmlLayer.events.on({
		"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect
	});
	
	function onFeatureSelect(event) {
		var feature = event.feature;
		message = '<div style="font-size:10px">' + feature.attributes.description + '</div>';
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
	}	
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);		
	}
}

function getURLParameter(name) {
	return decodeURI(
	(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
}