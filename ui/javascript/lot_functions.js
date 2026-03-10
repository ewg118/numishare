/************************************
 Written by Ethan Gruber, egruber@numismatics.org
 Library: jQuery, Leaflet
 Date modified: March 2026
 Description: Functions for lots, for example to display ajax results for coins in the lot.
 ************************************/
$(document).ready(function () {
    var popupStatus = 0;
    
    var path = $('#path').text();
    var pipeline = $('#pipeline').text();
    var lang = $('#lang').text();
    var query = $('#query').text();
    
    //load objects from lot on page load
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
    
    //make ajax results pageable
    $('#results').on('click', '.paging_div .page-nos .btn-toolbar .pagination a.pagingBtn', function (event) {
        var href = path + 'results_ajax' + $(this).attr('path');
        $. get (href, {
            pipeline: pipeline
        },
        function (data) {
            $('#results').html(data);
        });
        return false;
    });
});