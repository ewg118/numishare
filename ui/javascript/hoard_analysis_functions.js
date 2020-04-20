/*******************
VISUALIZATION FUNCTIONS
Author: Ethan Gruber
Modification Date: April 2020
Description: Functions used in the Hoard Display and Analyze pipelines
for manipulating forms and rendering tables in d3js
 ********************/

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
            if (decode(match[1]) == 'compare') {
                if (decode(match[2]).length > 0) {
                    compare.push(decode(match[2]));
                }
            } else {
                urlParams[decode(match[1])] = decode(match[2]);
            }
        }
        urlParams[ 'compare'] = compare;
    })();
    
    var path = $('#display_path').text();
    var page = $('#page').text();
    
    /**** RENDER CHART ****/
    //render the chart from request parameters on the distribution page and also validate the form
    if (page == 'page') {
        if (urlParams[ 'dist'] != null && urlParams[ 'compare'] != null) {
            renderDistChart(path, urlParams);
            validate('distributionForm');
        }
    }
    
    /*** AJAX-BASED FORM SUBMISSION***/
    $('.quant-form').submit(function () {
        //render distribution chart via ajax call to API rather than HTTP request parameters (analyze hoard page)
        if (page == 'record') {
            var formId = $(this).closest('form').attr('id');
            
            urlParams = {
            };
            //distribution params
            if ($('#' + formId).find('select[name=dist]').length > 0) {
                urlParams[ 'dist'] = $('#' + formId).find('select[name=dist]').val();
            }
            if ($('#' + formId).find('input[name=type]').length > 0) {
                urlParams[ 'type'] = $('#' + formId).find('input[name=type]:checked').val();
            }
            
            compare = new Array();
            //add the self ID
            if ($('#' + formId).find('input[name=compare][type=hidden]').length > 0) {
                compare.push($('#' + formId).find('input[name=compare][type=hidden]').val());
            }
            $('#' + formId + ' .compare-select').children('option:selected').each(function () {
                compare.push($(this).val());
            });
            
            urlParams[ 'compare'] = compare;
            
            params = new Array();
            //set the href value for the CSV download
            Object.keys(urlParams).forEach(function (key) {
                if (key == 'compare') {
                    for (var i = 0, len = urlParams[key].length; i < len; i++) {
                        params.push(key + '=' + urlParams[key][i]);
                    }
                } else if (key == 'filter') {
                    params.push('compare=' + urlParams[key]);
                } else {
                    params.push(key + '=' + urlParams[key]);
                }
            });
            
            //set bookmarkable page URL
            var href = path + 'analyze?' + params.join('&');
            $('.chart-container').children('div.control-row').children('a[title=Bookmark]').attr('href', href);
            
            //set CSV download URL
            params.push('format=csv');
            var href = path + 'apis/getHoardQuant?' + params.join('&');
            $('.chart-container').children('div.control-row').children('a[title=Download]').attr('href', href);
            
            //render d3js chart
            renderDistChart(path, urlParams)
            
            return false;
        }
    });
    
    /***** VALIDATE FORM WHEN CONTROLS ARE CHANGED *****/
    $('#categorySelect').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
        
        //when 'date' is selected or deselected, then enable/disable the cumulative radio button
        var dist = $(this).val();
        if (dist == 'date') {
            $('#' + formId).find('input[value=cumulative]').prop("disabled", false);
        } else {
            //disable the cumulative radio button and recheck the percentage as default
            if ($('#' + formId).find('input[name=type]:checked').val() == 'cumulative') {
                $('#' + formId).find('input[value=percentage]').prop("checked", true);
            }
            
            $('#' + formId).find('input[value=cumulative]').prop("disabled", true);
        }
    });
    
    $('.compare-select').on('change', function (event) {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    /***** TOGGLE OPTIONAL SETTINGS *****/
    $('.optional-button').click(function () {
        var formId = $(this).closest('form').attr('id');
        $('#' + formId + ' .optional-div').toggle('slow');
        return false;
    });
    
    
    /********* SOLR FILTERING FUNCTIONS **********/
    //show dialog to filter the hoard list
    $(".showFilter").each(function () {
        $(this).fancybox();
    });
    
    // total options for advanced search - used for unique id's on dynamically created elements
    var total_options = 1;
    
    // the boolean (and/or) items. these are set when a new search criteria option is created
    var gate_items = {
    };
    
    // focus the text field after selecting the field to search on
    $('.searchItemTemplate select').change(function () {
        $(this).siblings('.search_text').focus();
    })
    
    // assign the gate/boolean button click handler
    $('.gateTypeBtn').click(function () {
        gateTypeBtnClick($(this), total_options, gate_items);
    })
    
    //filter button activation
    $('#advancedSearchForm').submit(function () {
        var q = assembleQuery('advancedSearchForm');
        $('#distributionForm .filter-div').children('span').html(q);
        $('#distributionForm .filter-div').show();
        $.get(path + 'get_hoards', {
            q: q
        },
        function (data) {
            $('#distributionForm .compare-div').html(data);
        });
        $.fancybox.close();
        return false;
    });
    
    //remove filter
    $('.removeFilter').click(function () {
        $('#distributionForm .filter-div').hide();
        $.get(path + 'get_hoards', {
            q: '*'
        },
        function (data) {
            $('#distributionForm .compare-div').html(data);
        });
        return false;
    });
});

//render the chart through a JSON response from an API
function renderDistChart(path, urlParams) {
    var distValue = $('select[name=dist] option:selected').val();
    var distLabel = $('select[name=dist] option:selected').text();
    
    //set y axis
    if (urlParams[ 'type'] == 'count') {
        var y = 'count';
    } else {
        var y = 'percentage';
    }
    
    $.get(path + 'apis/getHoardQuant', $.param(urlParams, true),
    function (data) {
        $('.chart-container').removeClass('hidden');
        $('#distribution-chart').html('');
        $('#distribution-chart').height(600);
        
        if (urlParams[ 'type'] == 'cumulative') {
            new d3plus.LinePlot().data(data).groupBy("subset").x('value').y('percentage').shapeConfig({
                Line: {
                    strokeWidth: 2
                }
            }).tooltipConfig({
                title: function (d) {
                    return d[ "date"];
                },
                tbody:[[ function (d) {
                    return "Percentage: " + d[ "percentage"] + "%"
                }]]
            }).select("#distribution-chart").render();
        } else {
            new d3plus.BarChart().data(data).groupBy('subset').x(distValue).y(y).tooltipConfig({
                title: function (d) {
                    return d[ 'subset'];
                },
                tbody:[[ function (d) {
                    return d[distValue] + ': ' + d[y] + (y == 'percentage' ? '%': '')
                }]]
            }).select("#distribution-chart").render();
        }
    });
}

//validate the form. validation is basic compared to the SPARQL form
function validate(formId) {
    var elements = new Array();
    
    //ensure category drop down contains a value, but only for the distribution page
    if ($('#' + formId).find('select[name=dist]').val()) {
        elements.push(true);
        $('#visualize-cat-alert').addClass('hidden');
    } else {
        elements.push(false);
        $('#visualize-cat-alert').removeClass('hidden');
    }
    
    //count the number of compared hoards
    compare = new Array();
    //add the self ID
    if ($('#' + formId).find('input[name=compare]').length > 0) {
        compare.push($('#' + formId).find('input[name=compare]').val());
    }
    $('#' + formId + ' .compare-select').children('option:selected').each(function () {
        compare.push($(this).val());
    });
    
    //there must be 1 to 8 hoards for comparison
    if (compare.length >= 1 && compare.length <= 8) {
        elements.push(true);
        $('#hoard-count-alert').addClass('hidden');
    } else {
        elements.push(false);
        $('#hoard-count-alert').removeClass('hidden');
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
    } else {
        $('#' + formId).children('.visualize-submit').prop("disabled", true);
    }
}