/***
Author: Ethan Gruber
Date: January 2021
Function: Generate a Leaflet map for a specimen/type page and call the relevant GeoJSON serialization
 ***/
$(document).ready(function () {
    var id = $('title').attr('id');
    var collection_type = $('#collection_type').text();
    var path = $('#path').text();
    var pipeline = $('#pipeline').text();
    var lang = $('#lang').text();
    
    if ($('#mapcontainer').length > 0) {
        initialize_map(id, path, lang);
    }
});

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
    
    //add GeoJSON from AJAX
    $.getJSON(url, function (data) {
        var maxDensity = 0;
        $.each(data.features, function (key, value) {
            if (value.properties.type == 'findspot' && value.properties.hasOwnProperty('count') == true) {
                if (value.properties.count !== undefined) {
                    if (value.properties.count > maxDensity) {
                        maxDensity = value.properties.count;
                    }
                }
            }
        });
        
        var overlay = L.geoJson(data, {
            onEachFeature: onEachFeature,
            style: function (feature) {
                if (feature.geometry.type == 'Polygon') {
                    var fillColor = getFillColor(feature.properties.type);
                    
                    return {
                        color: fillColor
                    }
                }
            },
            pointToLayer: function (feature, latlng) {
                return renderPoints(feature, latlng, maxDensity);
            }
        }).addTo(map);
        
        map.fitBounds(overlay.getBounds());
    });
    
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
    
    /*****
     * Features for manipulating layers
     *****/
    function renderPoints(feature, latlng, maxDensity) {
        
        var fillColor = getFillColor(feature.properties.type);
        
        if (feature.properties.type == 'findspot' && feature.properties.hasOwnProperty('count')) {
            grade = maxDensity / 5;
            
            var radius = 5;
            if (feature.properties.count < Math.round(grade)) {
                radius = 5;
            } else if (feature.properties.count >= Math.round(grade) && feature.properties.count < Math.round(grade * 2)) {
                radius = 10;
            } else if (feature.properties.count >= Math.round(grade * 2) && feature.properties.count < Math.round(grade * 3)) {
                radius = 15;
            } else if (feature.properties.count >= Math.round(grade * 3) && feature.properties.count < Math.round(grade * 4)) {
                radius = 20;
            } else if (feature.properties.count >= Math.round(grade * 4)) {
                radius = 25;
            } else {
                radius = 5;
            }
            
            return new L.CircleMarker(latlng, {
                radius: radius,
                fillColor: fillColor,
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.6
            });
        } else {
            return new L.CircleMarker(latlng, {
                radius: 5,
                fillColor: fillColor,
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.6
            });
        }
    }
    
    function getFillColor (type) {
        var fillColor;
        switch (type) {
            case 'mint':
            case 'productionPlace':
            fillColor = '#6992fd';
            break;
            case 'findspot':
            fillColor = '#f98f0c';
            break;
            case 'hoard':
            fillColor = '#d86458';
            break;
            case 'subject':
            fillColor = '#00e64d';
            break;
            default:
            fillColor = '#efefef'
        }
        
        return fillColor;
    }
    
    function onEachFeature (feature, layer) {
        var str;
        //individual finds
        if (feature.properties.hasOwnProperty('gazetteer_uri') == false) {
            str = feature.label;
        } else {
            var str = '';
            //display hoard link and gazetteer link
            if (feature.hasOwnProperty('id') == true) {
                str += '<a href="' + feature.id + '">' + feature.label + '</a><br/>';
            }
            if (feature.properties.hasOwnProperty('gazetteer_uri') == true) {
                str += '<span>';
                if (feature.properties.type == 'hoard') {
                    str += '<b>Findspot: </b>';
                }
                str += '<a href="' + feature.properties.gazetteer_uri + '">' + feature.properties.toponym + '</a></span>';
                if (feature.properties.type == 'hoard' && feature.properties.hasOwnProperty('closing_date') == true) {
                    str += '<br/><b>Closing Date: </b>' + feature.properties.closing_date;
                }
            }
            if (feature.properties.hasOwnProperty('count') == true) {
				str += '<br/><b>Count: </b>' + feature.properties.count;
			}
        }
        layer.bindPopup(str);
    }
}