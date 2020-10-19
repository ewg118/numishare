/* Author: Ethan Gruber
 * Date: June 2020
 * Function: JQuery functions for the /symbols page in Numishare. Includes highlighting of symbol buttons and
 * fancybox/Leaflet popup of maps that query Nomisma.org API GeoJSON response for mints and hoards.
 */
$(document).ready(function () {
    //get URL parameters, from http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
    var urlParams;
    (window.onpopstate = function () {
        var match,
        pl = /\+/g, // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) {
            return decodeURIComponent(s.replace(pl, " "));
        },
        query = window.location.search.substring(1);
        
        urlParams = {
        };
        letters = new Array();
        while (match = search.exec(query)) {
            if (decode(match[1]) == 'symbol') {
                if (decode(match[2]).length > 0) {
                    letters.push(decode(match[2]));
                }
            } else {
                urlParams[decode(match[1])] = decode(match[2]);
            }
        }
        urlParams['letter'] = letters;
        urlParams['typeSeries'] = $('#typeSeries').text().split('|');
    })();
    
    $('.letter-button').click(function () {
        if ($(this).hasClass('active')) {
            $(this).removeClass('active');
        } else {
            $(this).addClass('active');
        }
    });
    
    $("#map_results").fancybox({
        beforeShow: function () {
            if ($('#resultMap').html().length == 0) {
                $('#resultMap').html('');
                initialize_map(urlParams);
            }
        }
    });
    
    $('#symbol-form').submit(function () {
        $('#symbol-form').children('input[type=hidden]').remove();
        
        $('.letter-button').each(function () {
            if ($(this).hasClass('active')) {
                $('#symbol-form').append('<input name="symbol" type="hidden" value="' + $(this).text() + '"/>');
            }
        });
    });
});

function initialize_map(urlParams) {
    
    var baselayers = $('#baselayers').text().split(',');
    var mapboxKey = $('#mapboxKey').text();
    
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
    
    var map = new L.Map('resultMap', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:[eval(baselayers[0])]
    });
    
    //add mintLayer from AJAX
    var mintLayer = L.geoJson.ajax('http://nomisma.org/apis/getMints?' + $.param(urlParams, true), {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    }).addTo(map);
    
    //add hoards, but don't make visible by default
    var hoardLayer = L.geoJson.ajax('http://nomisma.org/apis/getHoards?' + $.param(urlParams, true), {
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
        'Mints': mintLayer, 'Hoards': hoardLayer
    };
    
    L.control.layers(baseMaps, overlayMaps).addTo(map);
    
    //zoom to groups on AJAX complete
    mintLayer.on('data:loaded', function () {
        var group = new L.featureGroup([mintLayer, hoardLayer]);
        map.fitBounds(group.getBounds());
    }.bind(this));
    
    hoardLayer.on('data:loaded', function () {
        var group = new L.featureGroup([mintLayer, hoardLayer]);
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
            if (feature.properties.hasOwnProperty('closing_date') == true) {
                str += '<br/><span>';
                str += '<b>Closing Date: </b>' + feature.properties.closing_date;
            }
        }
        layer.bindPopup(str);
    }
}