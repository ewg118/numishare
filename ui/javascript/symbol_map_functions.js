$(document).ready(function () {
    var uri = $('#objectURI').text();
    initialize_map(uri);
});

function initialize_map(uri) {
    var baselayers = $('#baselayers').text().split(',');
    var mapboxKey = $('#mapboxKey').text();
    
    //baselayers
    var osm = L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'OpenStreetMap',
        maxZoom: 10
    });
    
    var imperium = L.tileLayer(
    'http://dare.ht.lu.se/tiles/imperium/{z}/{x}/{y}.png', {
        maxZoom: 10,
        attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a>. Map base: <a href="http://dare.ht.lu.se/" title="Digital Atlas of the Roman Empire, Department of Archaeology and Ancient History, Lund University, Sweden">DARE</a>, 2015 (cc-by-sa).'
    });
    var mb_physical = L.tileLayer(
    'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=' + mapboxKey, {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>', id: 'mapbox.streets', maxZoom: 10
    });
    
    //overlays
    var heatmapLayer = new HeatmapOverlay({
        "radius": .5,
        "maxOpacity": .8,
        "scaleRadius": true,
        "useLocalExtrema": true,
        latField: 'lat',
        lngField: 'lng',
        valueField: 'count'
    });
    
    var map = new L.Map('mapcontainer', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:[eval(baselayers[0])]
    });
    
    //add mintLayer from AJAX
    var mintLayer = L.geoJson.ajax('http://nomisma.org/apis/getMints?symbol=' + uri, {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    }).addTo(map);
    
    //add hoards, but don't make visible by default
    var hoardLayer = L.geoJson.ajax('http://nomisma.org/apis/getHoards?symbol=' + uri, {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    });
    
    //add individual finds layer, but don't make visible
    var findLayer = L.geoJson.ajax('http://nomisma.org/apis/getFindspots?symbol=' + uri, {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    });
    
    //load heatmapLayer after JSON loading concludes
    $.getJSON('http://nomisma.org/apis/heatmap?symbol=' + uri, function (data) {
        heatmapLayer.setData(data);
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
        'Mints': mintLayer, 'Hoards': hoardLayer, 'Finds': findLayer, 'Heatmap': heatmapLayer
    };
    
    L.control.layers(baseMaps, overlayMaps).addTo(map);
    
    //zoom to groups on AJAX complete
    mintLayer.on('data:loaded', function () {
        var group = new L.featureGroup([findLayer, mintLayer, hoardLayer]);
        map.fitBounds(group.getBounds());
    }.bind(this));
    
    hoardLayer.on('data:loaded', function () {
        var group = new L.featureGroup([findLayer, mintLayer, hoardLayer]);
        map.fitBounds(group.getBounds());
    }.bind(this));
    
    findLayer.on('data:loaded', function () {
        var group = new L.featureGroup([findLayer, mintLayer, hoardLayer]);
        map.fitBounds(group.getBounds());
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
            case 'hoard':
            fillColor = '#d86458';
            break;
            case 'find':
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
                str += '<a href="' + feature.properties.gazetteer_uri + '">' + feature.properties.toponym + '</a></span>'
            }
        }
        layer.bindPopup(str);
    }
}