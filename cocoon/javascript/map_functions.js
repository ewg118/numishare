/************************************
GET FACET TERMS IN RESULTS PAGE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This utilizes ajax to populate the list of terms in the facet category in the results page.
If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
************************************/
$(document).ready(function () {
	var popupStatus = 0;
	//set category button label on page load
	category_label();
	dateLabel();
	
	$("#backgroundPopup").livequery('click', function (event) {
		disablePopup();
	});
	
	/* INITIALIZE MAP */
	var q = '*:*';
	var collection_type = $('#collection_type').text();
	
	//initialize timemap if hoard
	if (collection_type == 'hoard') {
		initialize_timemap(q);
	} else {
		//initialize map
		var mintStyle = new OpenLayers.Style({
			pointRadius: "${radius}",
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
		}, {
			context: {
				radius: function (feature) {
					return Math.min(feature.attributes.count, 7) + 3;
				}
			}
		});
		//add findspot layer for hoards
		var hoardLayer = new OpenLayers.Layer.Vector("findspot", {
			styleMap: hoardStyle,
			eventListeners: {
				'loadend': kmlLoaded
			},
			strategies:[
			new OpenLayers.Strategy.Fixed(),
			new OpenLayers.Strategy.Cluster()],
			protocol: new OpenLayers.Protocol.HTTP({
				url: "findspots.kml?q=" + q,
				format: new OpenLayers.Format.KML({
					extractStyles: false,
					extractAttributes: true
				})
			})
		});
		var mintLayer = new OpenLayers.Layer.Vector("mint", {
			styleMap: mintStyle,
			eventListeners: {
				'loadend': kmlLoaded
			},
			strategies:[
			new OpenLayers.Strategy.Fixed(),
			new OpenLayers.Strategy.Cluster()],
			protocol: new OpenLayers.Protocol.HTTP({
				url: "mints.kml?q=" + q,
				format: new OpenLayers.Format.KML({
					extractStyles: false,
					extractAttributes: true
				})
			})
		});
		
		var map = new OpenLayers.Map('mapcontainer', {
			controls:[
			new OpenLayers.Control.PanZoomBar(),
			new OpenLayers.Control.Navigation(),
			new OpenLayers.Control.ScaleLine(),
			new OpenLayers.Control.LayerSwitcher({
				'ascending': true
			})]
		});
		
		var imperium = new OpenLayers.Layer.XYZ(
		"Imperium Romanum",[
		"http://pelagios.dme.ait.ac.at/tilesets/imperium/${z}/${x}/${y}.png"], {
			sphericalMercator: true,
			isBaseLayer: true,
			numZoomLevels: 12
		});
		
		map.addLayer(imperium);
		
		map.addLayer(mintLayer);
		map.addLayer(hoardLayer);
		
		
		//zoom to extent of world
		map.zoomTo('2');
		
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
	}
	
	//enable multiselect
	$(".multiselect").multiselect({
		//selectedList: 3,
		minWidth: 'auto',
		header: '<a class="ui-multiselect-none" href="#"><span class="ui-icon ui-icon-closethick"/><span>Uncheck all</span></a>',
		create: function () {
			var title = $(this).attr('title');
			var array_of_checked_values = $(this).multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			var length = array_of_checked_values.length;
			
			if (length > 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + length + ' selected');
			} else if (length > 0 && length <= 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + array_of_checked_values.join(', '));
			} else if (length == 0) {
				$(this).next('button').children('span:nth-child(2)').text(title);
			}
		},
		beforeopen: function () {
			var id = $(this) .attr('id');
			var q = getQuery();
			var category = id.split('-select')[0];
			var mincount = $(this).attr('mincount');
			
			$.get('maps_get_facet_options', {
				q: q, category: category, sort: 'index', limit: - 1, offset: 0, mincount: mincount
			},
			function (data) {
				$('#' + id) .html(data);
				$("#" + id).multiselect('refresh')
			});
		},
		//close menu: restore button title if no checkboxes are selected
		close: function () {
			var title = $(this).attr('title');
			var id = $(this) .attr('id');
			var array_of_checked_values = $(this).multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			if (array_of_checked_values.length == 0) {
				$('button[title=' + title + ']').children('span:nth-child(2)').text(title);
			}
		},
		click: function () {
			var title = $(this).attr('title');
			var id = $(this) .attr('id');
			var array_of_checked_values = $(this).multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			var length = array_of_checked_values.length;
			if (length > 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + length + ' selected');
			} else if (length > 0 && length <= 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + array_of_checked_values.join(', '));
			} else if (length == 0) {
				var q = getQuery();
				if (q.length > 0) {
					var category = id.split('-select')[0];
					var mincount = $(this).attr('mincount');
					$.get('maps_get_facet_options', {
						q: q, category: category, sort: 'index', limit: - 1, offset: 0, mincount: mincount
					},
					function (data) {
						$('#' + id) .attr('new_query', '');
						$('#' + id) .html(data);
						$('#' + id).multiselect('refresh');
					});
				}
			}
			
			if ($('#mapcontainer').length > 0) {
				//update map
				refresh_map();
			}
		},
		uncheckAll: function () {
			var id = $(this) .attr('id');
			q = getQuery();
			if (q.length > 0) {
				var category = id.split('-select')[0];
				var mincount = $(this).attr('mincount');
				$.get('maps_get_facet_options', {
					q: q, category: category, sort: 'index', limit: - 1, offset: 0, mincount: mincount
				},
				function (data) {
					$('#' + id) .attr('new_query', '');
					$('#' + id) .html(data);
					$('#' + id).multiselect('refresh');
				});
			}
			if ($('#mapcontainer').length > 0) {
				//update map
				refresh_map();
			}
		}
	}).multiselectfilter();
	
	function refresh_map() {
		var query = getQuery();
		
		//refresh maps.
		if (collection_type == 'hoard') {
			$('#timemap').html('<div id="mapcontainer"><div id="map"/></div><div id="timelinecontainer"><div id="timeline"/></div>');
			initialize_timemap(query);
		} else {
			newUrl = "mints.kml?q=" + query;
			
			mintLayer.loaded = false;
			mintLayer.setVisibility(true);
			//the refresh will force it to get the new KML data//
			mintLayer.refresh({
				force: true, url: newUrl
			});
			map.zoomToExtent(mintLayer.getDataExtent());
		}
	}
	
	$('#category_facet_link').hover(function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all ui-state-focus');
	},
	function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all');
	});
	
	$('.category-close') .click(function () {
		disablePopup();
	});
	
	$('#category_facet_link').click(function () {
		if (popupStatus == 0) {
			$("#backgroundPopup").fadeIn("fast");
			popupStatus = 1;
		}
		var list_id = $(this) .attr('id').split('_link')[0] + '-list';
		var category = $(this) .attr('id') .split('_link')[0];
		//var q = $(this) .attr('label');
		var q = getQuery();
		if ($('#' + list_id).html().indexOf('<li') < 0) {
			$.get('get_categories', {
				q: q, category: category, prefix: 'L1', fq: '*', section: 'collection', link: ''
			},
			function (data) {
				$('#' + list_id) .html(data);
			});
		}
		$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
	});
	
	//expand category when expand/compact image pressed
	$('.expand_category') .livequery('click', function (event) {
		var fq = $(this) .attr('id').split('__')[0];
		var list = fq.split('|')[1] + '__list';
		var prefix = $(this).attr('next-prefix');
		//var q = $(this) .attr('q');
		var q = getQuery();
		var section = $(this) .attr('section');
		var link = $(this) .attr('link');
		if ($(this) .children('img') .attr('src') .indexOf('plus') >= 0) {
			$.get('get_categories', {
				q: q, prefix: prefix, fq: '"' + fq.replace('_', ' ') + '"', link: link, section: section
			},
			function (data) {
				$('#' + list) .html(data);
			});
			$(this) .parent('.term') .children('.category_level') .show();
			$(this) .children('img') .attr('src', $(this) .children('img').attr('src').replace('plus', 'minus'));
		} else {
			$(this) .parent('.term') .children('.category_level') .hide();
			$(this) .children('img') .attr('src', $(this) .children('img').attr('src').replace('minus', 'plus'));
		}
	});
	
	//remove all ancestor or descendent checks on uncheck
	$('.term input') .livequery('click', function (event) {
		if ($(this) .is(':checked')) {
			$(this) .parents('.term') .children('input') .attr('checked', true);
		} else {
			$(this) .parent('.term') .children('.category_level') .find('input').attr('checked', false);
			//on unchecking, repopulate the categories
			if ($(this) .parent().parent().parent().children('span').attr('class') == 'expand_category') {
				var fq = $(this) .parent().parent().parent().children('.expand_category').attr('id').split('__')[0];
				var list = fq.split('|')[1] + '__list';
				var prefix = $(this).parent().parent().parent().children('.expand_category').attr('next-prefix');
				var section = $(this).parent().parent().parent().children('.expand_category') .attr('section');
				var link = $(this).parent().parent().parent().children('.expand_category') .attr('link');
				var query = getQuery();
				$.get('get_categories', {
					q: query, prefix: prefix, fq: '"' + fq.replace('_', ' ') + '"', link: link, section: section
				},
				function (data) {
					$('#' + list) .html(data);
				});
			} else {
				var query = getQuery();
				$.get('get_categories', {
					q: query, category: 'category_facet', prefix: 'L1', fq: '*', section: 'collection', link: ''
				},
				function (data) {
					$('#category_facet-list') .html(data);
				});
			}
		}
		var count_checked = 0;
		$('.term input').each(function () {
			if (this.checked) {
				count_checked++;
			}
		});
		
		if (count_checked > 0) {
			category_label();
		} else {
			$('#category_facet_link').attr('title', 'Category');
			$('#category_facet_link').children('span:nth-child(2)').html('Category');
		}
	});
	
	//handle expandable dates
	$('#century_num_link').hover(function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all ui-state-focus');
	},
	function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all');
	});
	
	$('.century-close').livequery('click', function (event) {
		disablePopup();
	});
	
	$('#century_num_link').livequery('click', function (event) {
		if (popupStatus == 0) {
			$("#backgroundPopup").fadeIn("fast");
			popupStatus = 1;
		}
		
		q = getQuery();
		var list_id = $(this) .attr('id').split('_link')[0] + '-list';
		$.get('get_centuries', {
			q: q
		},
		function (data) {
			$('#century_num-list').html(data);
		});
		
		$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
	});
	
	$('.expand_century').livequery('click', function (event) {
		var century = $(this).attr('century');
		if (century < 0) {
			century = "\\" + century;
		}
		//var q = $(this).attr('q');
		var q = getQuery();
		var expand_image = $(this).children('img').attr('src');
		//hide list if it is expanded
		if (expand_image.indexOf('minus') > 0) {
			$(this).children('img').attr('src', expand_image.replace('minus', 'plus'));
			$('#century_' + century + '_list') .hide();
		} else {
			$(this).children('img').attr('src', expand_image.replace('plus', 'minus'));
			//perform ajax load on first click of expand button
			if ($(this).parent('li').children('ul').html().indexOf('<li') < 0) {
				$.get('get_decades', {
					q: q, century: century
				},
				function (data) {
					$('#century_' + century + '_list').html(data);
				});
			}
			$('#century_' + century + '_list') .show();
		}
	});
	
	//check parent century box when a decade box is checked
	$('.decade_checkbox').livequery('click', function (event) {
		if ($(this) .is(':checked')) {
			//alert('test');
			$(this) .parent('li').parent('ul').parent('li') .children('input') .attr('checked', true);
		}
		//set label
		dateLabel();
		refresh_map();
	});
	//uncheck child decades when century is unchecked
	$('.century_checkbox').livequery('click', function (event) {
		if ($(this).not(':checked')) {
			$(this).parent('li').children('ul').children('li').children('.decade_checkbox').attr('checked', false);
		}
		//set label
		dateLabel();
		refresh_map();
	});
	
	$('a.pagingBtn') .livequery('click', function (event) {
		var href = 'results_ajax' + $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#results') .html(data);
		});
		return false;
	});
	
	//clear query
	$('#clear_all').livequery('click', function (event) {
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
			$('#category_facet-list') .parent('div').attr('style', 'width: 192px;');
			$('#century_num-list') .parent('div').attr('style', 'width: 192px;');
			popupStatus = 0;
		}
	}
	
	/********************
	OpenLayers functions for object collections
	********************/
	function kmlLoaded() {
		map.zoomToExtent(mintLayer.getDataExtent());
	}
	
	function onPopupClose(evt) {
		map.removePopup(map.popups[0]);
	}
	
	function onFeatureSelect(event) {
		var q = getQuery();
		
		var name = this.name;
		var message = '';
		var place_uris = new Array();
		var place_names = new Array();
		if (event.feature.cluster.length > 12) {
			message = '<div style="font-size:10px">' + event.feature.cluster.length + ' ' + name + 's found at this location';
			for (var i in event.feature.cluster) {
				place_uris.push(event.feature.cluster[i].attributes[ 'description']);
				place_names.push(event.feature.cluster[i].attributes[ 'name']);
			}
		} else if (event.feature.cluster.length > 1 && event.feature.cluster.length <= 12) {
			message = '<div style="font-size:10px;width:300px;">' + event.feature.cluster.length + ' ' + name + 's found at this location: ';
			for (var i in event.feature.cluster) {
				place_uris.push(event.feature.cluster[i].attributes[ 'description']);
				place_names.push(event.feature.cluster[i].attributes[ 'name']);
				message += event.feature.cluster[i].attributes[ 'name'];
				if (i < event.feature.cluster.length - 1) {
					message += ', ';
				}
			}
		} else if (event.feature.cluster.length == 1) {
			place_uris.push(event.feature.cluster[0].attributes[ 'description']);
			place_names.push(event.feature.cluster[0].attributes[ 'name']);
			message = '<div style="font-size:10px">' + name + ' of ' + event.feature.cluster[0].attributes[ 'name'];
		}
		
		//assemble the place query
		var place_query = '';
		if (event.feature.cluster.length > 1) {
			place_query += '(';
			for (var i in place_uris) {
				place_query += name + '_uri:"' + place_uris[i] + '"';
				if (i < place_uris.length - 1) {
					place_query += ' OR ';
				}
			}
			place_query += ')';
		} else {
			place_query = name + '_uri:"' + place_uris[0] + '"';
		}
		var query = q + ' AND ' + place_query;
		
		message += '.<br/><br/>';
		message += "<a href='#results' class='show_coins' q='" + query + "'>View</a> records that meet the search criteria from " + (event.feature.cluster.length > 1? 'these ' + name + 's': 'this ' + name) + " [<a href='#results' class='show_coins' q='" + query + " AND imagesavailable:true'>with images</a>]" + ' (results below map).';
		message += '</div>';
		
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
		
		$('.show_coins').livequery('click', function (event) {
			var query = $(this).attr('q');
			var lang = $('input[name=lang]').val();
			$.get('results_ajax', {
				q: query,
				lang: lang
			},
			function (data) {
				$('#results') .html(data);
			});
			return false;
		});
	}
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
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
				eventIconPath: "images/timemap/"
			},
			datasets:[ {
				title: "Title",
				theme: "red",
				type: "kml", // Data to be loaded in KML - must be a local URL
				options: {
					url: "hoards.kml?q=" + q// KML file to load
				}
			}],
			bandIntervals:[
			Timeline.DateTime.DECADE,
			Timeline.DateTime.CENTURY]
		});
	}
});