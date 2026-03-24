/************************************
 Written by Ethan Gruber, egruber@numismatics.org
 Library: jQuery, Leaflet
 Date modified: March 2026
 Description: Functions for lots, for example to display ajax results for coins in the lot.
 ************************************/
$(document).ready(function () {
    var popupStatus = 0;
    
    var path = $('#path').text();
    var lang = $('#lang').text();
    var query = $('#query').text();
    var mapboxKey = $('#mapboxKey').text();
    var baselayers = $('#baselayers').text().split(',');
    var collection_type = $('#collection_type').text();
    
    //load objects from lot on page load, if the div is present
    if ($('#results').length) {
        $. get (path + 'results_ajax', {
            q: query, lang: lang, pipeline: collection_type
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
    }
    
    //load distribution map if the Leaflet map div is present
    if ($('#resultMap').length) {
        initialize_map(query, path, mapboxKey, baselayers, collection_type);
    }
    
    //make ajax results pageable
    $('#results').on('click', '.paging_div .page-nos .btn-toolbar .pagination a.pagingBtn', function (event) {
        var href = path + 'results_ajax' + $(this).attr('path');
        $. get (href, {
            pipeline: collection_type
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
});