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
        var mintLayer = L.geoJson.ajax(path + "mints.geojson?q=" + q + '&department=' + department, {
            pointToLayer: renderPoints
        }).addTo(map);
        
        var hoardLayer = L.geoJson.ajax(path + "hoards.geojson?q=" + q + '&department=' + department, {
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
        
        //enable popup
        mintLayer.on('click', function (e) {
            renderPopup(e);
        });
        hoardLayer.on('click', function (e) {
            renderHoardPopup(e);
        });
    } else {
        //load mints, subjects, and findspots as markers for coin types and physical specimen collections
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
    
    /*****
     * LEAFLET FUNCTIONS
     *****/
    function refreshMap() {
        var query = getQuery();
        //refresh maps.
        if (collection_type == 'hoard') {
            mintUrl = path + "mints.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            hoardUrl = path + "hoards.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            
            mintLayer.refresh(mintUrl);
            hoardLayer.refresh(hoardUrl);
        } else {
            mintUrl = path + "mints.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            hoardUrl = path + "findspots.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            subjectUrl = path + "subjects.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
            
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
    
    function renderHoardPopup(e) {
        var str = "<h4><a href='" + e.layer.feature.properties.objectURI + "' target='_blank'>" + e.layer.feature.properties.objectTitle + "</a></h4>" +
        "<div><strong>Findspot: </strong>" + e.layer.feature.properties.name + "<a href='" + e.layer.feature.properties.uri + "' target='_blank'> <span class='glyphicon glyphicon-new-window'/></a>";
        
        if (e.layer.feature.properties.hasOwnProperty('closing_date')){
            str += "<br/><strong>Closing Date: </strong>" + e.layer.feature.properties.closing_date; 
        } else if (e.layer.feature.properties.hasOwnProperty('deposit')){
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
            fillColor = '#6992fd';
            break;
            case 'findspot', 'hoard':
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