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
    
    var calculate = getURLParameter('calculate');
    if (calculate != 'null') {
        $('#tabs a[href="#quantitative"]').tab('show');
        if (calculate == 'date') {
            $('#quant-tabs a[href="#dateTab"]').tab('show');
        }
    }
    
    if ($('#mapcontainer').length > 0) {
        initialize_map(id, path, lang);
    }
});

/*function initialize_timemap(id) {
    var langStr = getURLParameter('lang');
    if (langStr == 'null') {
        var lang = '';
    } else {
        var lang = langStr;
    }
    
    var tm;
    tm = TimeMap.init({
        mapId: "map", // Id of map div element (required)
        timelineId: "timeline", // Id of timeline div element (required)
        options: {
            eventIconPath: $('#include_path').text() + "/images/timemap/"
        },
        datasets:[ {
            title: "Mints",
            type: "json",
            options: {
                url: "../apis/get?id=" + id + "&format=json&lang=" + lang
            }
        }],
        bandIntervals:[
        Timeline.DateTime.DECADE,
        Timeline.DateTime.CENTURY]
    });
}*/

function getURLParameter(name) {
    return decodeURI(
    (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
}

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
    'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=' + mapboxKey, {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>', id: 'mapbox.streets', maxZoom: 10
    });
    
    var map = new L.Map('mapcontainer', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:[eval(baselayers[0])]
    });
    
    //add mintLayer from AJAX
    var overlay = L.geoJson.ajax(url, {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    }).addTo(map);
    
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
    
    //zoom to groups on AJAX complete
    overlay.on('data:loaded', function () {
        map.fitBounds(overlay.getBounds());
    }.bind(this));
    
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
            break;
            default:
            fillColor = '#efefef'
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
    
    function onEachFeature (feature, layer) {
        var label = feature.properties.name;
        if (feature.properties.hasOwnProperty('uri')) {
            str = label + ' <a href="' + feature.properties.uri + '" target="_blank"><span class="glyphicon glyphicon-new-window"/></a>';
        } else {
            str = label;
        }
        
        layer.bindPopup(str);
    }
}