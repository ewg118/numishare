/************************************
GET FACET TERMS IN RESULTS PAGE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This utilizes ajax to populate the list of terms in the facet category in the results page.
If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
 ************************************/
$(document).ready(function () {
	var popupStatus = 0;
	var firstrun = true;
	var langStr = getURLParameter('lang');
	var departmentStr = getURLParameter('department');
	
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	if (departmentStr == 'null') {
		var department = '';
	} else {
		var department = departmentStr;
	}
	
	var path = $('#path').text();
	var pipeline = $('#pipeline').text();
	
	//set hierarchical labels on load
	$('.hierarchical-facet').each(function () {
		var field = $(this).attr('id').split('_hier')[0];
		var title = $(this).attr('title');
		hierarchyLabel(field, title);
	});
	if ($('#century_num').length > 0) {
		dateLabel();
	}
	
	$("#backgroundPopup").on('click', function (event) {
		disablePopup();
	});
	
	/* INITIALIZE MAP */
	var q = '*:*';
	var collection_type = $('#collection_type').text();
	
	//initialize timemap if hoard
	if (collection_type == 'hoard') {
		initialize_timemap(q);
	} else {
		var path = $('#path').text();
		var mapboxKey = $('#mapboxKey').text();
		var baselayers = $('#baselayers').text().split(',');
		
		//baselayers
		var osm = L.tileLayer(
		'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
			attribution: 'OpenStreetMap',
			maxZoom: 18
		});
		
		var imperium = L.tileLayer(
		'http://dare.ht.lu.se/tiles/imperium/{z}/{x}/{y}.png', {
			maxZoom: 11,
			attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a>. Map base: <a href="http://dare.ht.lu.se/" title="Digital Atlas of the Roman Empire, Department of Archaeology and Ancient History, Lund University, Sweden">DARE</a>, 2015 (cc-by-sa).'
		});
		
		var mb_physical = L.tileLayer(
		'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=' + mapboxKey, {
			attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
			'<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
			'Imagery © <a href="http://mapbox.com">Mapbox</a>', id: 'mapbox.streets'
		});
		
		var map = new L.Map('mapcontainer', {
			center: new L.LatLng(0, 0),
			zoom: 4,
			layers:[eval(baselayers[0])]
		});
		
		//add mintLayer from AJAX
		var mintLayer = L.geoJson.ajax(path + "mints.geojson?q=" + q + '&department=' + department, {
			pointToLayer: renderPoints
		}).addTo(map);
		
		var subjectLayer = L.geoJson.ajax(path + "subjects.geojson?q=" + q + '&department=' + department, {
			pointToLayer: renderPoints
		}).addTo(map);
		
		//add hoards, but don't make visible by default
		var markers = '';
		var findspotLayer = L.geoJson.ajax(path + "findspots.geojson?q=" + q + '&department=' + department, {
			pointToLayer: renderPoints
		});
		
		//add controls
		var baseMaps = {
		};
		//add baselayers
		var i;
		for (i = 0; i < baselayers.length; i++) {
			var label;
			switch (baselayers[i]) {
				case 'osm': label = "OpenStreetMap"; break;
				case 'imperium': label = 'Imperium Romanum'; break;
				case 'mb_physical': label = 'Terrain and Streets'; break;
			}
			baseMaps[label] = eval(baselayers[i]);
		}
		
		var overlayMaps = {
			'Mints': mintLayer,
			'Subjects': subjectLayer
		};
		
		//add controls
		var layerControl = L.control.layers(baseMaps, overlayMaps).addTo(map);
		
		//zoom to groups on AJAX complete
		mintLayer.on('data:loaded', function () {
			var group = new L.featureGroup([mintLayer, findspotLayer, subjectLayer]);
			map.fitBounds(group.getBounds());
		}.bind(this));
		
		findspotLayer.on('data:loaded', function () {
			markers = L.markerClusterGroup();
			layerControl.addOverlay(markers, 'Findspots');
			markers.addLayer(findspotLayer);
			map.addLayer(markers);
			
			var group = new L.featureGroup([mintLayer, findspotLayer, subjectLayer]);
			map.fitBounds(group.getBounds());
		}.bind(this));
		
		subjectLayer.on('data:loaded', function () {
			var group = new L.featureGroup([mintLayer, findspotLayer, subjectLayer]);
			map.fitBounds(group.getBounds());
		}.bind(this));
		
		//enable popup
		mintLayer.on('click', function (e) {
			renderPopup(e);
		});
		findspotLayer.on('click', function (e) {
			renderPopup(e);
		});
		subjectLayer.on('click', function (e) {
			renderPopup(e);
		});
	}
	
	//multiselect facets
	$('.multiselect').multiselect({
		buttonWidth: '250px',
		enableCaseInsensitiveFiltering: true,
		maxHeight: 250,
		buttonText: function (options, select) {
			if (options.length == 0) {
				return select.attr('title');
			} else if (options.length > 2) {
				return select.attr('title') + ': ' + options.length;
			} else {
				var selected = '';
				options.each(function () {
					selected += $(this).text() + ', ';
				});
				label = selected.substr(0, selected.length - 2);
				if (label.length > 20) {
					label = label.substr(0, 20) + '...';
				}
				return select.attr('title') + ': ' + label;
			}
		},
		onChange: function (element, checked) {
			//if there are 0 selected checks in the multiselect, re-initialize ajax to populate list
			id = element.parent('select').attr('id');
			if ($('#' + id).val() == null) {
				var q = getQuery();
				var category = id.split('-select')[0];
				var mincount = $(this).attr('mincount');
				$.get(path + 'get_facet_options', {
					q: q, category: category, mincount: mincount, lang: lang, pipeline: pipeline
				},
				function (data) {
					$('#ajax-temp').html(data);
					$('#' + id).html('');
					$('#' + id).attr('new_query', '');
					$('#ajax-temp option').each(function () {
						$(this).clone().appendTo('#' + id);
					});
					$("#" + id).multiselect('rebuild');
				});
			}
			if ($('#mapcontainer').length > 0) {
				//update map
				refreshMap();
			}
		}
	});
	
	//on open
	$('button.multiselect').on('click', function () {
		var q = getQuery();
		var id = $(this).parent('div').prev('select').attr('id');
		var mincount = $(this).parent('div').prev('select').attr('mincount');
		var category = id.split('-select')[0];
		$.get(path + 'get_facet_options', {
			q: q, category: category, mincount: mincount, lang: lang, pipeline: pipeline
		},
		function (data) {
			$('#ajax-temp').html(data);
			$('#' + id).attr('new_query', '');
			$('#' + id).html('');
			$('#ajax-temp option').each(function () {
				$(this).clone().appendTo('#' + id);
			});
			$("#" + id).multiselect('rebuild');
		});
	});
	
	$('#results').on('click', '.paging_div .page-nos .btn-toolbar .pagination a.pagingBtn', function (event) {
		var href = path + 'results_ajax' + $(this).attr('href');
		$.get(href, {
			pipeline: pipeline
		},
		function (data) {
			$('#results').html(data);
		});
		return false;
	});
	
	//clear query
	$('#results').on('click', 'h1 small #clear_all', function () {
		$('#results').html('');
		return false;
	});
	
	/***************************/
	//@Author: Adrian "yEnS" Mato Gondelle
	//@website: www.yensdesign.com
	//@email: yensamg@gmail.com
	//@license: Feel free to use it, but keep this credits please!
	/***************************/
	
	//disabling popup with jQuery magic!
	function disablePopup() {
		//disables popup only if it is enabled
		if (popupStatus == 1) {
			$("#backgroundPopup").fadeOut("fast");
			$('#category_hier-list').parent('div').attr('style', 'width: 192px;');
			$('#findspot_hier-list').parent('div').attr('style', 'width: 192px;');
			$('#century_num-list').parent('div').attr('style', 'width: 192px;');
			popupStatus = 0;
		}
	}
	
	function getURLParameter(name) {
		return decodeURI(
		(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
	}
	
	
	/*****
	 * LEAFLET FUNCTIONS
	 *****/
	function refreshMap() {
		var query = getQuery();
		//refresh maps.
		if (collection_type == 'hoard') {
			$('#timemap').html('<div id="mapcontainer" class="fullscreen"><div id="map"/></div><div id="timelinecontainer"><div id="timeline"/></div>');
			initialize_timemap(query);
		} else {
			mintUrl = path + "mints.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
			hoardUrl = path + "findspots.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
			subjectUrl = path + "subjects.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
			
			layerControl.removeLayer(markers);
			map.removeLayer(markers);
			mintLayer.refresh(mintUrl);
			findspotLayer.refresh(hoardUrl);
			subjectLayer.refresh(subjectUrl);
		}
	}
	
	/*****
	 * Generate a popup for the various types of layers
	 *****/
	function renderPopup(e) {
		var query = getQuery();
		query += ' AND ' + e.layer.feature.properties.type + '_uri:"' + e.layer.feature.properties.uri + '"';
		var str = e.layer.feature.properties.type + ": <a href='#results' class='show_coins' q='" + query + "'>" + e.layer.feature.properties.name + "</a> <a href='" + e.layer.feature.properties.uri + "' target='_blank'><span class='glyphicon glyphicon-new-window'/></a>";
		e.layer.bindPopup(str).openPopup();
		$('.show_coins').on('click', function (event) {
			var query = $(this).attr('q');
			var lang = $('input[name=lang]').val();
			$.get(path + 'results_ajax', {
				q: query, lang: lang, pipeline: pipeline
			},
			function (data) {
				$('#results').html(data);
			}).done(function () {
				$('a.thumbImage').fancybox({
					type: 'image',
					beforeShow: function () {
						this.title = '<a href="' + this.element.attr('id') + '">' + this.element.attr('title') + '</a>'
					},
					helpers: {
						title: {
							type: 'inside'
						}
					}
				});
			});
			return false;
		});
	}
	
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
	
	/********************
	TimeMap function for hoard collections
	 ********************/
	function initialize_timemap(q) {
		var tm;
		tm = TimeMap.init({
			mapId: "map", // Id of map div element (required)
			timelineId: "timeline", // Id of timeline div element (required)
			options: {
				eventIconPath: $('#include_path').text() + "/images/timemap/"
			},
			datasets:[ {
				title: "Title",
				theme: "red",
				type: "json", // Data to be loaded in KML - must be a local URL
				options: {
					url: path + "hoards.json?q=" + q + (lang.length > 0 ? '&lang=' + lang: '')
				}
			}],
			bandIntervals:[
			Timeline.DateTime.DECADE,
			Timeline.DateTime.CENTURY]
		});
	}
});