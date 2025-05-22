/************************************
 GET FACET TERMS IN RESULTS PAGE
 Written by Ethan Gruber, gruber@numismatics.org
 Library: jQuery, Leaflet
 Date modified: May 2025
 Description: This utilizes ajax to populate the list of terms in the facet category in the results page.
 If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
 ************************************/
$(document).ready(function () {
    var popupStatus = 0;
    var firstrun = true;
    
    //get lang if applicable
    var langStr = getURLParameter('lang');
    if (langStr == 'null') {
        var lang = '';
    } else {
        var lang = langStr;
    }
    
    var qStr = getURLParameter('q');
    if (qStr == 'null') {
        var q = '*:*';
    } else {
        var q = qStr;
    }
    
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
    
    /* INITIALIZE MAP */
    var collection_type = $('#collection_type').text();
    
    //Leaflet variables
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
    'https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
        maxZoom: 10,
        attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a>. Map base: <a href="https://dh.gu.se/dare/" title="Digital Atlas of the Roman Empire, Department of Archaeology and Ancient History, Lund University, Sweden">DARE</a>, 2015 (cc-by-sa).'
    });
    
    var mb_physical = L.tileLayer(
    'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>', id: 'mapbox/outdoors-v11', maxZoom: 12, accessToken: mapboxKey
    });
    
    var map = new L.Map('mapcontainer', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:[eval(baselayers[0])]
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
    
    if (collection_type == 'hoard') {
        //load individual hoards and mints for a hoard collection
        var mintLayer = L.geoJson.ajax(path + "mints.geojson?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''), {
            pointToLayer: renderPoints
        }).addTo(map);
        
        var hoardLayer = L.geoJson.ajax(path + "hoards.geojson?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''), {
            pointToLayer: renderPoints
        }).addTo(map);
        
        var overlayMaps = {
            'Hoards': hoardLayer,
            'Mints': mintLayer
        };
        
        L.Control.Button = L.Control.extend({
            options: {
                position: 'topleft'
            },
            onAdd: function (map) {
                var container = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
                var button = L.DomUtil.create('a', 'glyphicon glyphicon-filter', container);
                L.DomEvent.disableClickPropagation(button);
                L.DomEvent.on(button, 'click', function () {
                    $.fancybox({
                        'href': '#map_filters'
                    });
                });
                
                container.title = "Filter";
                
                return container;
            }
        });
        var control = new L.Control.Button()
        control.addTo(map);
        
        L.control.Legend({
            position: "bottomleft",
            legends:[ {
                label: "Marker1",
                type: "image",
                url: "marker/marker-red.png"
            }]
        }).addTo(map);
        
        //add controls
        var layerControl = L.control.layers(baseMaps, overlayMaps).addTo(map);
        
        //zoom to groups on AJAX complete
        mintLayer.on('data:loaded', function () {
            var group = new L.featureGroup([hoardLayer, mintLayer]);
            map.fitBounds(group.getBounds());
        }.bind(this));
        
        hoardLayer.on('data:loaded', function () {
            var group = new L.featureGroup([hoardLayer, mintLayer]);
            map.fitBounds(group.getBounds());
        }.bind(this));
        
        //enable popup
        mintLayer.on('click', function (e) {
            renderPopup(e);
        });
        hoardLayer.on('click', function (e) {
            renderHoardPopup(e);
        });
    } else {
        //load mints, subjects, and findspots as markers for coin types and physical specimen collections
        var mintLayer = L.geoJson.ajax(path + "mints.geojson?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''), {
            pointToLayer: renderPoints
        }).addTo(map);
        
        var subjectLayer = L.geoJson.ajax(path + "subjects.geojson?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''), {
            pointToLayer: renderPoints
        }).addTo(map);
        
        //add hoards, but don't make visible by default
        var findspotLayer = L.geoJson.ajax(path + "findspots.geojson?q=" + q + (lang.length > 0 ? '&lang=' + lang: ''), {
            pointToLayer: renderPoints
        }).addTo(map);
        
        var overlayMaps = {
            'Mints': mintLayer,
            'Findspots': findspotLayer,
            'Subjects': subjectLayer
        };
        
        L.Control.Button = L.Control.extend({
            options: {
                position: 'topleft'
            },
            onAdd: function (map) {
                var container = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
                var button = L.DomUtil.create('a', 'glyphicon glyphicon-filter', container);
                L.DomEvent.disableClickPropagation(button);
                L.DomEvent.on(button, 'click', function () {
                    $.fancybox({
                        'href': '#map_filters'
                    });
                });
                
                container.title = "Filter";
                
                return container;
            }
        });
        var control = new L.Control.Button()
        control.addTo(map);
        
        L.control.Legend({
            position: "bottomleft",
            symbolWidth: 24,
            symbolHeight: 24,
            legends: JSON.parse($('#legend').text())
        }).addTo(map);
        
        //add controls
        var layerControl = L.control.layers(baseMaps, overlayMaps).addTo(map);
        
        //zoom to groups on AJAX complete
        mintLayer.on('data:loaded', function () {
            var group = new L.featureGroup([mintLayer, findspotLayer, subjectLayer]);
            map.fitBounds(group.getBounds());
        }.bind(this));
        
        findspotLayer.on('data:loaded', function () {
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
    
    //assemble query on form submission
    $('#facet_form').submit(function () {
        //update map
        var q = getQuery();
        refreshMap(q);
        
        //close window
        $.fancybox.close();
        
        //update permalink
        $('#permalink').attr('href', '?q=' + q);  
        $('#permalink').parent('p').removeClass('hidden');
        
        return false;
    });
    
    $('#permalink').click(function () {
        var url = window.location.href.split('?')[0] + $(this).attr('href');
        navigator.clipboard.writeText(url);
        
        $('#permalink-tooltip').fadeIn(3);
        $('#permalink-tooltip').fadeOut();
        
        return false;
    });
    
    
    //make ajax results pageable
    $('#results').on('click', '.paging_div .page-nos .btn-toolbar .pagination a.pagingBtn', function (event) {
        var href = path + 'results_ajax' + $(this).attr('href');
        $. get (href, {
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
    
    /*****
     * LEAFLET FUNCTIONS
     *****/
    function refreshMap(q) {
        var query = encodeURI(q);
        //refresh maps.
        if (collection_type == 'hoard') {
            mintUrl = path + "mints.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            hoardUrl = path + "hoards.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            
            mintLayer.refresh(mintUrl);
            hoardLayer.refresh(hoardUrl);
        } else {
            mintUrl = path + "mints.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            findspotUrl = path + "findspots.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            subjectUrl = path + "subjects.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            
            mintLayer.refresh(mintUrl);
            findspotLayer.refresh(findspotUrl);
            subjectLayer.refresh(subjectUrl);
        }
    }
    
    /*****
     * Generate a popup for the various types of layers
     *****/
    function renderPopup(e) {
        var query = getQuery();
        query += ' AND ' + e.layer.feature.properties.type + '_uri:"' + e.layer.feature.properties.uri + '"';
        
        var type = e.layer.feature.properties.type;
        type = type[0].toUpperCase() + type.substring(1);
        
        var str = "<strong>" + type + "</strong>: <a href='#results' class='show_coins' q='" + query + "'>" + e.layer.feature.properties.name + "</a> <a href='" + e.layer.feature.properties.uri + "' target='_blank'><span class='glyphicon glyphicon-new-window'/></a>";
        str += '<br/><strong>Count</strong>: ' + e.layer.feature.properties.count;
        
        e.layer.bindPopup(str).openPopup();
        $('.show_coins').on('click', function (event) {
            var query = $(this).attr('q');
            var lang = $('input[name=lang]').val();
            $. get (path + 'results_ajax', {
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
    
    function renderHoardPopup(e) {
        var str = "<h4><a href='" + e.layer.feature.properties.uri + "' target='_blank'>" + e.layer.feature.properties.name + "</a></h4>" +
        "<div><strong>Findspot: </strong>" + e.layer.feature.properties.toponym + "<a href='" + e.layer.feature.properties.gazetteer_uri + "' target='_blank'> <span class='glyphicon glyphicon-new-window'/></a>";
        
        if (e.layer.feature.properties.hasOwnProperty('closing_date')) {
            str += "<br/><strong>Closing Date: </strong>" + e.layer.feature.properties.closing_date;
        } else if (e.layer.feature.properties.hasOwnProperty('deposit')) {
            str += "<br/><strong>Deposit: </strong>" + e.layer.feature.properties.deposit;
        }
        
        str += "</div>";
        e.layer.bindPopup(str).openPopup();
    }
    
    /*****
     * Features for manipulating layers
     *****/
    function renderPoints(feature, latlng) {
        var fillColor;
        switch (feature.properties.type) {
            case 'mint':
            case 'productionPlace':
            fillColor = '#6992fd';
            break;
            case 'hoard':
            fillColor = '#d86458';
            break;
            case 'findspot':
            fillColor = '#f98f0c';
            break;
            case 'subject':
            fillColor = '#a1d490';
        }
        
        return new L.CircleMarker(latlng, {
            radius: feature.properties.radius,
            fillColor: fillColor,
            color: "#000",
            weight: 1,
            opacity: 1,
            fillOpacity: 0.6
        });
    }
});