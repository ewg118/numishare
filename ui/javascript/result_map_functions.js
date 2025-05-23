/************************************
 Written by Ethan Gruber, egruber@numismatics.org
 Library: jQuery, Leaflet
 Date modified: May 2025
 Description: Display the Leaflet map on the browse page, based on the Solr query
 ************************************/
$(document).ready(function () {
    var q = $('#current-query').text();
    
    
    $("#map_results").click(function () {
        $('#resultMap').toggle();
        //only load map if the div is empty
        if ($('#resultMap').html().length == 0) {
            $('#resultMap').html('')            
            initialize_map(q);
        }
        
        if ($(this).text() == 'View Map') {
            $(this).text('Hide Map');
        } else {
            $(this).text('View Map'); 
        }
        
        return false;
    });
    
    function initialize_map(q) {
        var path = $('#path').text();
        var mapboxKey = $('#mapboxKey').text();
        var baselayers = $('#baselayers').text().split(',');
        var collection_type = $('#collection_type').text();
        
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
        
        var map = new L.Map('resultMap', {
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
        
        q = encodeURI(q);
        if (collection_type == 'hoard') {
            var mintLayer = L.geoJson.ajax(path + "mints.geojson?q=" + q, {
                onEachFeature: onEachFeature,
                pointToLayer: renderPoints
            }).addTo(map);
            
            var hoardLayer = L.geoJson.ajax(path + "hoards.geojson?q=" + q, {
                onEachFeature: onEachFeature,
                pointToLayer: renderPoints
            }).addTo(map);
            
            var overlayMaps = {
                'Hoards': hoardLayer,
                'Mints': mintLayer
            };
            
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
        } else {
            
            var mintLayer = L.geoJson.ajax(path + "mints.geojson?q=" + q, {
                onEachFeature: onEachFeature,
                pointToLayer: renderPoints
            }).addTo(map);
            
            var subjectLayer = L.geoJson.ajax(path + "subjects.geojson?q=" + q, {
                onEachFeature: onEachFeature,
                pointToLayer: renderPoints
            }).addTo(map);
            
            var findspotLayer = L.geoJson.ajax(path + "findspots.geojson?q=" + q, {
                onEachFeature: onEachFeature,
                pointToLayer: renderPoints
            }).addTo(map);
            
            var overlayMaps = {
                'Mints': mintLayer,
                'Findspots': findspotLayer,
                'Subjects': subjectLayer
            };
            
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
        
        function onEachFeature (feature, layer) {
            var label = feature.properties.name;
            var collection_type = $('#collection_type').text();
            str = '';
            
            //link directly to hoards in the result map functions for hoard databases
            if (collection_type == 'hoard' && feature.properties.type == 'hoard') {
                str += '<a href="' + feature.properties.uri + '">' + label + '</a>';
                if (feature.properties.hasOwnProperty('gazetteer_uri') == true) {
                    str += '<br/><b>Findspot: </b>';
                    str += '<a href="' + feature.properties.gazetteer_uri + '">' + feature.properties.toponym + '</a>';
                }
                if (feature.properties.hasOwnProperty('closing_date') == true) {
                    str += '<br/><b>Closing Date: </b>' + feature.properties.closing_date;
                }
                if (feature.properties.hasOwnProperty('deposit') == true) {
                    str += '<br/><b>Deposit: </b>' + feature.properties.deposit;
                }
            } else {
                if (feature.properties.type == 'subject') {
                    var facet = 'subjectPlace';
                } else {
                    var facet = feature.properties.type;
                }
                
                if (q.length > 0) {
                    var query = q + ' AND ' + facet + '_facet:"' + label + '"';
                } else {
                    var query = facet + '_facet:"' + label + '"';
                }
                
                if (q.indexOf('mint_facet') !== -1) {
                    var str = label;
                } else {
                    var str = "<a href='results?q=" + query + "'>" + label + '</a>';
                }
                if (feature.properties.hasOwnProperty('uri')) {
                    str += ' <a href="' + feature.properties.uri + '" target="_blank"><span class="glyphicon glyphicon-new-window"/></a>';
                }
            }
            
            
            layer.bindPopup(str);
        }
    }
    
    function getURLParameter(name) {
        return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
    }
});