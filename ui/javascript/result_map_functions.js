$(document).ready(function () {
	var q = $('#current-query').text();
	var collection_type = $('#collection_type').text();
	$("#map_results").fancybox({
		beforeShow: function () {
			if ($('#resultMap').html().length == 0) {
				$('#resultMap').html('');
				initialize_map(q, collection_type);
			}
		}
	});
});

function initialize_map(q, collection_type) {
	var langStr = getURLParameter('lang');
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	/***** DECLARE BASELAYERS ******/
	var google_physical = new OpenLayers.Layer.Google("Google Physical", {
		type: google.maps.MapTypeId.TERRAIN
	});
	var imperium = new OpenLayers.Layer.XYZ(
	"Imperium Romanum",[
	"http://dare.ht.lu.se/tiles/imperium/${z}/${x}/${y}.png"], {
		sphericalMercator: true,
		isBaseLayer: true,
		numZoomLevels: 12,
		attribution: '<a href="http://imperium.ahlfeldt.se">Digital Atlas of the Roman Empire</a>, hosted by <a href="http://pelagios-project.blogspot.com">Pelagios</a>.'
	});
	var osm = new OpenLayers.Layer.OSM();
	
	var baselayers = $('#baselayers').text().split(',');
	
	var map = new OpenLayers.Map('resultMap', {
		controls:[
		new OpenLayers.Control.PanZoomBar(),
		new OpenLayers.Control.Navigation(),
		new OpenLayers.Control.ScaleLine(),
		new OpenLayers.Control.Attribution(),
		new OpenLayers.Control.LayerSwitcher({
			'ascending': true
		})]
	});
	
	var mintStyle = new OpenLayers.Style({
		pointRadius: "${radius}",
		//pointRadius: "5",
		fillColor: "#6992fd",
		fillOpacity: 0.8,
		strokeColor: "#000000",
		strokeWidth: 2,
		strokeOpacity: 0.8
	},
	{
		context: {
			radius: function (feature) {
				return Math.min(feature.attributes.count, 7) + 3;
			}
		}
	});
	var hoardStyle = new OpenLayers.Style({
		pointRadius: "${radius}",
		//pointRadius: "5",
		fillColor: "#d86458",
		fillOpacity: 0.8,
		strokeColor: "#000000",
		strokeWidth: 2,
		strokeOpacity: 0.8
	},
	{
		context: {
			radius: function (feature) {
				return Math.min(feature.attributes.count, 7) + 3;
			}
		}
	});
	var subjectStyle = new OpenLayers.Style({
		pointRadius: "${radius}",
		//pointRadius: "5",
		fillColor: "#00e64d",
		fillOpacity: 0.8,
		strokeColor: "#000000",
		strokeWidth: 2,
		strokeOpacity: 0.8
	}, {
		context: {
			radius: function (feature) {
				return Math.min(feature.attributes.count, 7) + 3;
			}
		}
	});
	var mintLayer = new OpenLayers.Layer.Vector("Mints", {
		styleMap: mintStyle,
		
		eventListeners: {
			'loadend': kmlLoaded
		},
		strategies:[
		new OpenLayers.Strategy.Fixed(),
		new OpenLayers.Strategy.Cluster()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: "mints.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''),
			format: new OpenLayers.Format.KML({
				extractStyles: false,
				extractAttributes: true
			})
		})
	});
	var subjectLayer = new OpenLayers.Layer.Vector("Subjects", {
		styleMap: subjectStyle,
		eventListeners: {
			'loadend': kmlLoaded
		},
		strategies:[
		new OpenLayers.Strategy.Fixed(),
		new OpenLayers.Strategy.Cluster()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: "subjects.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''),
			format: new OpenLayers.Format.KML({
				extractStyles: false,
				extractAttributes: true
			})
		})
	});
	
	//add findspot layer for hoards
	var hoardLayer = new OpenLayers.Layer.Vector("Findspots", {
		styleMap: hoardStyle,
		eventListeners: {
			'loadend': kmlLoaded
		},
		strategies:[
		new OpenLayers.Strategy.Fixed(),
		new OpenLayers.Strategy.Cluster()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: "findspots.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''),
			format: new OpenLayers.Format.KML({
				extractStyles: false,
				extractAttributes: true
			})
		})
	});
	
	//add baselayers
	var i;
	for (i = 0; i < baselayers.length; i++) {
		map.addLayer(eval(baselayers[i]));
	}
	
	map.addLayer(mintLayer);
	map.addLayer(hoardLayer);
	map.addLayer(subjectLayer);
	
	function kmlLoaded() {
		var bounds = new OpenLayers.Bounds();
		bounds.extend(mintLayer.getDataExtent());
		bounds.extend(hoardLayer.getDataExtent());
		bounds.extend(subjectLayer.getDataExtent());
		map.zoomToExtent(bounds);
	}
	
	//enable events for mint selection
	SelectControl = new OpenLayers.Control.SelectFeature([mintLayer, hoardLayer, subjectLayer], {
		clickout: true,
		multiple: false,
		hover: false
	});
	
	map.addControl(SelectControl);
	SelectControl.activate();
	
	mintLayer.events.on({
		"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect
	});
	hoardLayer.events.on({
		"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect
	});
	subjectLayer.events.on({
		"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect
	});
	
	function onPopupClose(evt) {
		map.removePopup(map.popups[0]);
	}
	
	function onFeatureSelect(event) {
		var message = '';
		var places = new Array();
		if (event.feature.cluster.length > 12) {
			message = '<div style="font-size:10px">' + event.feature.cluster.length + ' places found at this location';
			for (var i in event.feature.cluster) {
				places.push(event.feature.cluster[i].attributes[ 'name']);
			}
		} else if (event.feature.cluster.length > 1 && event.feature.cluster.length <= 12) {
			message = '<div style="font-size:10px;width:300px;">' + event.feature.cluster.length + ' places found at this location: ';
			for (var i in event.feature.cluster) {
				places.push(event.feature.cluster[i].attributes[ 'name']);
				message += event.feature.cluster[i].attributes[ 'name'];
				if (i < event.feature.cluster.length - 1) {
					message += ', ';
				}
			}
		} else if (event.feature.cluster.length == 1) {
			places.push(event.feature.cluster[0].attributes[ 'name']);
			message = '<div style="font-size:10px">' + event.feature.cluster[0].attributes[ 'name'];
		}
		
		message += '</div>';
		
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
	}
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
	}
	
	function getURLParameter(name) {
		return decodeURI(
		(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
	}
}