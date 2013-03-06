$(document).ready(function () {
	var id = $('title').attr('id');
	initialize_timemap(id);
});

function initialize_timemap(id) {
	var url = "../apis/get?id=" + id + "&format=json";
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
	
	//additional facets
	/*$('#term-list').children('li').each(function () {
		var facet = $(this).attr('class');
		var value = $(this).text();
		obj = {};
		obj.id = facet.split('_')[0];
		obj.title = facet.split('_')[0];
		obj.type = 'kml';
		obj.theme = 'green';
		obj.optional = true;
		obj.options = {
			url: '../mints.kml?q=' + facet + ':"' + value + '"'
		};
		datasets.push(obj);
	});*/
	
	var tm;
	tm = TimeMap.init({
		mapId: "map", // Id of map div element (required)
		timelineId: "timeline", // Id of timeline div element (required)
		options: {
			eventIconPath: "../images/timemap/"
		},
		datasets: datasets,
		bandIntervals:[
		Timeline.DateTime.DECADE,
		Timeline.DateTime.CENTURY]
	});
}



function initialize_map(id, path) {
	
	map = new OpenLayers.Map('mapcontainer', {
		controls:[
		new OpenLayers.Control.PanZoomBar(),
		new OpenLayers.Control.Navigation(),
		new OpenLayers.Control.ScaleLine(),
		new OpenLayers.Control.LayerSwitcher({
			'ascending': true
		})]
	});
	
	//google physical
	var imperium = new OpenLayers.Layer.XYZ(
	"Imperium Romanum",[
	"http://pelagios.dme.ait.ac.at/tilesets/imperium/${z}/${x}/${y}.png"], {
		sphericalMercator: true,
		isBaseLayer: true,
		numZoomLevels: 12
	});
	
	map.addLayer(imperium);
	
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
	
	//add other facets
	$('#term-list').children('li').each(function () {
		var facet = $(this).attr('class');
		var value = $(this).text();
		
		var fillColor = '#' + Math.floor(Math.random() * 16777215).toString(16);
		var strokeColor = '#' + Math.floor(Math.random() * 16777215).toString(16);
		
		map.addLayer(new OpenLayers.Layer.Vector(facet.split('_')[0] + ': ' + value, {
			visibility: false,
			styleMap: new OpenLayers.Style({
				pointRadius: "${radius}", fillColor: fillColor, fillOpacity: 0.8, strokeColor: strokeColor, strokeWidth: 2, strokeOpacity: 0.8
			},
			{
				context: {
					radius: function (feature) {
						return Math.min(feature.attributes.count, 7) + 3;
					}
				}
			}),
			strategies:[
			new OpenLayers.Strategy.Fixed(),
			new OpenLayers.Strategy.Cluster()],
			protocol: new OpenLayers.Protocol.HTTP({
				url: path + 'mints.kml?q=' + facet + ':"' + value + '"',
				format: new OpenLayers.Format.KML({
					extractStyles: false,
					extractAttributes: true
				})
			})
		}));
	});
	
	//add origin point last
	map.addLayer(kmlLayer);
	
	function kmlLoaded() {
		map.zoomToExtent(kmlLayer.getDataExtent());
		map.zoomTo('4');
	}
	
	/*************** OBJECT KML FEATURES ******************/
	objectControl = new OpenLayers.Control.SelectFeature([kmlLayer], {
		clickout: true,
		//toggle: true,
		multiple: false,
		hover: false,
		//toggleKey: "ctrlKey",
		//multipleKey: "shiftKey"
	});
	
	map.addControl(objectControl);
	objectControl.activate();
	kmlLayer.events.on({
		"featureselected": onObjectSelect, "featureunselected": onFeatureUnselect
	});
	
	function onObjectSelect(event) {
		var feature = event.feature;
		message = '<div style="font-size:10px">' + feature.attributes.description + '</div>';
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
	}
	/*************** FACET FEATURE LAYERS ******************/
	//get the list of layers, excluding Google Physical and the source layer
	var layer_string = '';
	for (i = 1; i < map.layers.length - 1; i++) {
		layer_string += 'map.layers[' + i + ']';
		if (i < map.layers.length - 2) {
			layer_string += ',';
		}
	}
	
	//activate controls
	eval('selectControl = new OpenLayers.Control.SelectFeature([' + layer_string + '], {clickout: true, multiple: false, hover: false})');
	map.addControl(selectControl);
	selectControl.activate();
	
	for (i in map.layers) {
		map.layers[i].events.on({
			"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect
		});
	}
	
	function onFeatureSelect(event) {
		var message = '';
		var mints = new Array();
		mints.length = 0;
		if (event.feature.cluster.length > 12) {
			message = '<div style="font-size:10px;width:300px;">' + event.feature.cluster.length + ' mints found at this location';
			for (var i in event.feature.cluster) {
				mints.push(event.feature.cluster[i].attributes[ 'name']);
			}
		} else if (event.feature.cluster.length > 1 && event.feature.cluster.length <= 12) {
			message = '<div style="font-size:10px;width:300px;">' + event.feature.cluster.length + ' mints found at this location: ';
			for (var i in event.feature.cluster) {
				mints.push(event.feature.cluster[i].attributes[ 'name']);
				message += event.feature.cluster[i].attributes[ 'name'];
				if (i < event.feature.cluster.length - 1) {
					message += ', ';
				}
			}
		} else if (event.feature.cluster.length == 1) {
			mints.push(event.feature.cluster[0].attributes[ 'name']);
			message = '<div style="font-size:10px;width:300px;">Mint of ' + event.feature.cluster[0].attributes[ 'name'];
		}
		
		var mint_query = '';
		if (event.feature.cluster.length > 1) {
			mint_query += '(';
			for (var i in mints) {
				mint_query += 'mint_facet:"' + mints[i] + '"';
				if (i < mints.length - 1) {
					mint_query += ' OR ';
				}
			}
			mint_query += ')';
		} else {
			mint_query = 'mint_facet:"' + mints[0] + '"';
		}
		message += '.<br/><div id="checks"><h3>Select Facets</h3></div>';
		
		message += '<br/>';
		message += "<a href='' class='show_coins' target='_blank'>View</a> coins that meet the search critera from " + (event.feature.cluster.length > 1? 'these mints': 'this mint') + '.';
		message += '</div>';
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
		
		for (i in map.layers) {
			var name = map.layers[i].name;
			if (name.indexOf(': ') > 0 && map.layers[i].visibility == true) {
				var facet = name.split(': ')[0] + '_facet';
				var term = '"' + name.split(': ')[1] + '"';
				var query = facet + ':' + term + ' AND ' + mint_query;
				$.ajax({
					url: path + 'get_map_checkbox?q=' + query,
					type: "get",
					dataType: "html",
					success: function (data) {
						$('#checks') .append(data + '<br/>');
					}
				});
			}
		}
		
		$('.show_coins').click(function () {
			var checked_values = new Array();
			$('#checks').children('input:checked').each(function () {
				checked_values.push($(this).attr('value'));
			});
			var query_string = '';
			if (checked_values.length > 1) {
				var query_string = '(' + checked_values.join(' OR ') + ') AND ';
			} else if (checked_values.length == 1) {
				var query_string = checked_values[0] + ' AND ';
			}
			query = path + 'results?q=' + query_string + mint_query;
			$(this).attr('href', query);
		});
	}
	
	function onPopupClose(evt) {
		$('.show_coins').attr('href', '');
		map.removePopup(map.popups[0]);
	}
	
	function onFeatureUnselect(event) {
		$('.show_coins').attr('href', '');
		map.removePopup(map.popups[0]);
	}
}