function initialize_map(q, collection_type) {
	var langStr = getURLParameter('lang');
	if (langStr == 'null'){
		var lang = '';
	} else {
		var lang = langStr;
	}

	map = new OpenLayers.Map('resultMap', {
		controls:[
		new OpenLayers.Control.PanZoomBar(),
		new OpenLayers.Control.Navigation(),
		new OpenLayers.Control.ScaleLine(),]
	});
	
	var mintStyle = new OpenLayers.Style({
		pointRadius: "${radius}",
		//pointRadius: "5",
		fillColor: "#0000ff",
		fillOpacity: 0.8,
		strokeColor: "#000072",
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
		fillColor: "#00a000",
		fillOpacity: 0.8,
		strokeColor: "#006100",
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
	var imperium = new OpenLayers.Layer.XYZ(
	"Imperium Romanum",[
	"http://pelagios.dme.ait.ac.at/tilesets/imperium/${z}/${x}/${y}.png"], {
		sphericalMercator: true,
		isBaseLayer: true,
		numZoomLevels: 12
	});
	
	map.addLayer(imperium);
	var mintLayer = new OpenLayers.Layer.Vector("KML", {
		styleMap: mintStyle,
		
		eventListeners: {
			'loadend': kmlLoaded
		},
		strategies:[
		new OpenLayers.Strategy.Fixed(),
		new OpenLayers.Strategy.Cluster()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: "mints.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang : ''),
			format: new OpenLayers.Format.KML({
				extractStyles: false,
				extractAttributes: true
			})
		})
	});
	map.addLayer(mintLayer);
	
	//add findspot layer for hoards
	var hoardLayer = new OpenLayers.Layer.Vector("KML", {
		styleMap: hoardStyle,
		eventListeners: {
			'loadend': kmlLoaded
		},
		strategies:[
		new OpenLayers.Strategy.Fixed(),
		new OpenLayers.Strategy.Cluster()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: "findspots.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang : ''),
			format: new OpenLayers.Format.KML({
				extractStyles: false,
				extractAttributes: true
			})
		})
	});
	map.addLayer(hoardLayer);
	
	function kmlLoaded() {
		if (collection_type == 'hoard') {
			map.zoomToExtent(hoardLayer.getDataExtent());
		} else {
			map.zoomToExtent(mintLayer.getDataExtent());
		}
		
		if (q == '*:*') {
			map.zoomTo('3');
		} else {
			map.zoomTo('5');
		}
	}
	
	//enable events for mint selection
	SelectControl = new OpenLayers.Control.SelectFeature([mintLayer, hoardLayer], {
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
	        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
	    );
	}
}