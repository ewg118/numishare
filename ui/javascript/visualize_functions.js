/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
 ************************************/
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
        compare = new Array();
        while (match = search.exec(query)) {
            urlParams[decode(match[1])] = decode(match[2]);
        }
    })();
    
    var path = './';
    
    
    /**** RENDER CHART ****/
    //render the chart from request parameters on the distribution page
    if (urlParams[ 'category'] != null && urlParams[ 'compare'] != null) {
        renderDistChart(path, urlParams);
        validate('distributionForm');
    }
    
    //observe changes in drop down menus for validation
    $('#categorySelect').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    /********* COMPARE FUNCTIONS **********/
    //add customQuery
    $(".addQuery").click(function () {
        var href = $(this).attr('href');
        var id = $(this).attr('id');
        
        //set paramName
        $('#paramName').html(id);
        
        //load fancybox
        $.fancybox({
            'href': href
        });
        return false;
    });
    
    //filter button activation
    $('#advancedSearchForm').submit(function () {
        var q = assembleQuery('advancedSearchForm');
        var param = $('#paramName').text();
        
        //insert new query
        var newQuery = '<div class="compareQuery"><b>Comparison Query: </b><span class="query">' + q + '</span><a href="#" class="removeQuery"><span class="glyphicon glyphicon-remove"/>Remove Query</a></div>'
        $('#' + param + 'Div').append(newQuery);
        
        //close fancybox
        $.fancybox.close();
        
        //clear searchBox for next addition
        $('.inputContainer').empty();
        
        //reset template
        var tpl = cloneTemplate();
        $('.inputContainer').html(tpl);
        
        // display the entire new template
        tpl.fadeIn('fast');
        
        //validate form
        validate('distributionForm');
        
        return false;
    });
    
    //remove comparison or custom queries
    $('#compareQueryDiv').on('click', '.compareQuery .removeQuery', function () {
        $(this).parent('div').remove();
        validate('distributionForm');
        return false;
    });
});

function renderDistChart(path, urlParams) {
    var distValue = $('select[name=category] option:selected').val();
    var distLabel = $('select[name=category] option:selected').text();
    
    if (urlParams[ 'type'] == 'count') {
        var y = 'count';
    } else {
        var y = 'percentage';
    }
    
    $.get(path + 'apis/getSolrDistribution', $.param(urlParams, true),
    function (data) {
        //$('#distribution .chart-container').removeClass('hidden');
        $('#distribution-chart').html('');
        $('#distribution-chart').height(600);
        new d3plus.BarChart().data(data).groupBy('subset').x(distValue).y(y).tooltipConfig({
            title: function (d) {
                return d[ 'subset'];
            },
            tbody:[[ function (d) {
                return y + ': ' + d[y] + (y == 'percentage' ? '%': '')
            }]]
        }).select("#distribution-chart").render();
    });
}

//validate the form. validation is basic compared to the SPARQL form
function validate(formId) {
    var elements = new Array();
    
    //ensure category drop down contains a value, but only for the distribution page
    if ($('#categorySelect').val()) {
        elements.push(true);
    } else {
        elements.push(false);
    }
    
    //there must be at least one compare container on the analsyis page
    if ($('#' + formId + ' .compareQuery span.query').length >= 1) {
        elements.push(true);
        $('#empty-query-alert').addClass('hidden');
    } else {
        elements.push(false);
        $('#empty-query-alert').removeClass('hidden');
    }
    
    //if there is a false element to the form OR if there is only one element (i.e., the category, then the form is invalid
    if (elements.indexOf(false) !== -1) {
        var valid = false;
    } else {
        var valid = true;
    }
    
    //enable/disable button
    if (valid == true) {
        $('#' + formId).children('.visualize-submit').prop("disabled", false);
        
        var queries = new Array();
        $('#' + formId + ' .compareQuery span.query').each(function () {
            queries.push($(this).text());
        });
        
        compare = queries.join('|');
        $('#' + formId).children('input[name=compare]').val(compare);
    } else {
        $('#' + formId).children('.visualize-submit').prop("disabled", true);
    }
}