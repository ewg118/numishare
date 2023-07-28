/************************************
Author: Ethan Gruber
Last modified: April 2020
Function: initiate functions on hoard page, incuding Leaflet maps and GeoJSON API call
 ************************************/
$(document).ready(function () {
    var id = $('title').attr('id');
    var path = $('#path').text();
    var lang = $('#lang').text();
    
    $('.toggle-coin').click(function () {
        var id = $(this).attr('id').split('-')[0];
        $('#' + id + '-div').toggle('slow');
        if ($(this).text() == '[more]') {
            $(this).text('[less]');
        } else {
            $(this).text('[more]');
        }
        return false;
    });
    
    //initialize Leaflet map
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
    
    $.getJSON(url, function (data) {
        var maxDensity = 0;
        $.each(data.features, function (key, value) {
            if (value.properties.average_count !== undefined) {
                if (value.properties.average_count > maxDensity) {
                    maxDensity = value.properties.average_count;
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
    
    //add controls
    var layerControl = L.control.layers(baseMaps).addTo(map);
    /*****
     * Features for manipulating layers
     *****/
    function renderPoints(feature, latlng, maxDensity) {
        grade = maxDensity / 5;
        
        var radius = 5;
        if (feature.properties.average_count < Math.round(grade)) {
            radius = 5;
        } else if (feature.properties.average_count >= Math.round(grade) && feature.properties.average_count < Math.round(grade * 2)) {
            radius = 10;
        } else if (feature.properties.average_count >= Math.round(grade * 2) && feature.properties.average_count < Math.round(grade * 3)) {
            radius = 15;
        } else if (feature.properties.average_count >= Math.round(grade * 3) && feature.properties.average_count < Math.round(grade * 4)) {
            radius = 20;
        } else if (feature.properties.average_count >= Math.round(grade * 4)) {
            radius = 25;
        } else {
            radius = 5;
        }
        
        var fillColor = getFillColor(feature.properties.type);
        
        return new L.CircleMarker(latlng, {
            radius: radius,
            fillColor: fillColor,
            color: "#000",
            weight: 1,
            opacity: 1,
            fillOpacity: 0.6
        });
    }
    
    function getFillColor (type) {
        var fillColor;
        switch (type) {
            case 'mint':
            fillColor = '#6992fd';
            break;
            case 'findspot':
            fillColor = '#d86458';
            break;
            case 'subject':
            fillColor = '#a1d490';
            break;
            default:
            fillColor = '#efefef'
        }
        
        return fillColor;
    }
    
    function onEachFeature (feature, layer) {
        var label = feature.properties.name;
        if (feature.properties.hasOwnProperty('uri')) {
            str = label + ' <a href="' + feature.properties.uri + '" target="_blank"><span class="glyphicon glyphicon-new-window"/></a>';
            if (feature.properties.hasOwnProperty('average_count')) {
                str += '<br/>Specimens: ' + feature.properties.average_count;
            }
        } else {
            str = label;
        }
        
        layer.bindPopup(str);
    }
}