/************************************
GET FACET TERMS IN RESULTS PAGE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This utilizes ajax to populate the list of terms in the facet category in the results page.
If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
 ************************************/
$(document).ready(function () {
	var popupStatus = 0;
	var langStr = getURLParameter('lang');
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
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
		
		
		//initialize map
		var mintStyle = new OpenLayers.Style({
			pointRadius: "${radius}",
			fillColor: "#6992fd",
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
		},
		{
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
				url: path + "findspots.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''),
				format: new OpenLayers.Format.KML({
					extractStyles: false,
					extractAttributes: true
				})
			})
		});
		//add findspot layer for subjects
		var subjectLayer = new OpenLayers.Layer.Vector("subject", {
			styleMap: subjectStyle,
			eventListeners: {
				'loadend': kmlLoaded
			},
			strategies:[
			new OpenLayers.Strategy.Fixed(),
			new OpenLayers.Strategy.Cluster()],
			protocol: new OpenLayers.Protocol.HTTP({
				url: path + "subjects.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''),
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
				url: path + "mints.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''),
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
		
		map.addLayer(mintLayer);
		map.addLayer(hoardLayer);
		map.addLayer(subjectLayer);
		
		//zoom to extent of world
		map.zoomTo('2');
		
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
	}
	
	//multiselect facets
	$('.multiselect').multiselect({
		buttonWidth: '250px',
		enableFiltering: true,
		maxHeight: 250,
		buttonText: function (options, select) {
			if (options.length == 0) {
				return select.attr('title') + ' <b class="caret"></b>';
			} else if (options.length > 2) {
				return select.attr('title') + ': ' + options.length + ' selected <b class="caret"></b>';
			} else {
				var selected = '';
				options.each(function () {
					selected += $(this).text() + ', ';
				});
				label = selected.substr(0, selected.length - 2);
				if (label.length > 20) {
					label = label.substr(0, 20) + '...';
				}
				return select.attr('title') + ': ' + label + ' <b class="caret"></b>';
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
	
	function refreshMap() {
		var query = getQuery();
		
		//refresh maps.
		if (collection_type == 'hoard') {
			$('#timemap').html('<div id="mapcontainer" class="fullscreen"><div id="map"/></div><div id="timelinecontainer"><div id="timeline"/></div>');
			initialize_timemap(query);
		} else {
			mintUrl = path + "mints.kml?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
			hoardUrl = path + "findspots.kml?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
			subjectUrl = path + "subjects.kml?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
			
			mintLayer.loaded = false;
			mintLayer.setVisibility(true);
			//the refresh will force it to get the new KML data//
			mintLayer.refresh({
				force: true, url: mintUrl
			});
			hoardLayer.refresh({
				force: true, url: hoardUrl
			});
			subjectLayer.refresh({
				force: true, url: subjectUrl
			});
			var bounds = new OpenLayers.Bounds();
			bounds.extend(mintLayer.getDataExtent());
			bounds.extend(hoardLayer.getDataExtent());
			bounds.extend(subjectLayer.getDataExtent());
			map.zoomToExtent(bounds);
		}
	}
	
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
	
	/***************** DRILLDOWN HIERARCHICAL FACETS ********************/
	/*$('.hierarchical-facet').hover(function () {
	$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all ui-state-focus');
	},
	function () {
	$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all');
	});
	
	$('.hier-close') .click(function () {
	disablePopup();
	return false;
	});
	
	$('.hierarchical-facet').click(function () {
	if (popupStatus == 0) {
	$("#backgroundPopup").fadeIn("fast");
	popupStatus = 1;
	}
	var list_id = $(this) .attr('id').split('_link')[0] + '-list';
	var field = $(this) .attr('id').split('_hier')[0];
	var q = getQuery();
	if ($('#' + list_id).html().indexOf('<li') < 0) {
	$.get(path + 'get_hier', {
	q: q, field: field, prefix: 'L1', fq: '*', section: 'collection', link: '', lang: lang, pipeline: pipeline
	},
	function (data) {
	$('#' + list_id) .html(data);
	});
	}
	$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
	return false;
	});
	
	//expand category when expand/compact image pressed
	$('.expand_category') .on('click', function (event) {
	var fq = $(this).next('input').val();
	var list = $(this) .attr('id').split('__')[0].split('|')[1] + '__list';
	var field = $(this).attr('field');
	var prefix = $(this).attr('next-prefix');
	var q = getQuery();
	var section = $(this) .attr('section');
	var link = $(this) .attr('link');
	if ($(this) .children('img') .attr('src') .indexOf('plus') >= 0) {
	$.get(path + 'get_hier', {
	q: q, field: field, prefix: prefix, fq: '"' + fq + '"', link: link, section: section, lang: lang, pipeline: pipeline
	},
	function (data) {
	$('#' + list) .html(data);
	});
	$(this) .parent('li') .children('.' + field + '_level') .show();
	$(this) .children('img') .attr('src', $(this) .children('img').attr('src').replace('plus', 'minus'));
	} else {
	$(this) .parent('li') .children('.' + field + '_level') .hide();
	$(this) .children('img') .attr('src', $(this) .children('img').attr('src').replace('minus', 'plus'));
	}
	});
	
	//remove all ancestor or descendent checks on uncheck
	$('.h_item input') .on('click', function (event) {
	var field = $(this).closest('.ui-multiselect-menu').attr('id').split('-')[0];
	var title = $('.' + field + '-multiselect-checkboxes').attr('title');
	
	var count_checked = 0;
	$('#' + field + '_hier-list input:checked').each(function () {
	count_checked++;
	});
	
	if (count_checked > 0) {
	hierarchyLabel(field, title);
	refreshMap();
	} else {
	$('#' + field + '_hier_link').attr('title', title);
	$('#' + field + '_hier_link').children('span:nth-child(2)').html(title);
	}
	});*/
	
	/***************** DRILLDOWN FOR DATES ********************/
	/*$('#century_num_link').hover(function () {
	$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all ui-state-focus');
	},
	function () {
	$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all');
	});
	
	$('.century-close').on('click', function (event) {
	disablePopup();
	});
	
	$('#century_num_link').on('click', function (event) {
	if (popupStatus == 0) {
	$("#backgroundPopup").fadeIn("fast");
	popupStatus = 1;
	}
	
	q = getQuery();
	var list_id = $(this) .attr('id').split('_link')[0] + '-list';
	if ($('#' + list_id).html().indexOf('<li') < 0) {
	$.get(path + 'get_centuries', {
	q: q, pipeline: pipeline
	},
	function (data) {
	$('#century_num-list').html(data);
	});
	}
	
	$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
	});
	
	$('.expand_century').on('click', function (event) {
	var century = $(this).attr('century');
	
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
	$.get(path + 'get_decades', {
	q: q, century: '"' + century + '"', pipeline: pipeline
	},
	function (data) {
	$('#century_' + century + '_list').html(data);
	});
	}
	$('#century_' + century + '_list') .show();
	}
	});
	
	//check parent century box when a decade box is checked
	$('.decade_checkbox').on('click', function (event) {
	if ($(this) .is(':checked')) {
	$(this) .parent('li').parent('ul').parent('li') .children('input') .attr('checked', true);
	}
	//set label
	dateLabel();
	refreshMap();
	});
	//uncheck child decades when century is unchecked
	$('.century_checkbox').on('click', function (event) {
	if ($(this).not(':checked')) {
	$(this).parent('li').children('ul').children('li').children('.decade_checkbox').attr('checked', false);
	}
	//set label
	dateLabel();
	refreshMap();
	});*/
	
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
	
	/********************
	OpenLayers functions for object collections
	 ********************/
	function kmlLoaded() {
		var bounds = new OpenLayers.Bounds();
		bounds.extend(mintLayer.getDataExtent());
		bounds.extend(hoardLayer.getDataExtent());
		bounds.extend(subjectLayer.getDataExtent());
		map.zoomToExtent(bounds);
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
		message += "<a href='#results' class='show_coins' q='" + query + "'>View</a> records that meet the search criteria from " + (event.feature.cluster.length > 1 ? 'these ' + name + 's': 'this ' + name) + ' (results below map).';
		message += '</div>';
		
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
		
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
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
	}
	
	function getURLParameter(name) {
		return decodeURI(
		(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
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