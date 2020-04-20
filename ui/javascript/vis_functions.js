/*******
DISTRIBUTION VISUALIZATION FUNCTIONS
Modified: March 2019
Function: These are the functions for generating charts and graphs with d3js
 *******/

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
    
    var path = '../';
    var page = $('#page').text();
    var interfaceType = $('#interface').text();
    
    /**** RENDER CHART ****/
    //render the chart from request parameters on the distribution page
    if (interfaceType == 'distribution' && page == 'page') {
        if (urlParams[ 'dist'] != null && (urlParams[ 'filter'] || urlParams[ 'compare'] != null)) {
            renderDistChart(path, urlParams);
        }
    } else if (interfaceType = 'metrical' && page == 'page') {
        if (urlParams[ 'measurement'] != null && (urlParams[ 'filter'] || urlParams[ 'compare'] != null)) {
            renderMetricalChart(path, urlParams);
        }
    }
    
    //render the chart on button click ajax trigger on ID page--do not reload page with request params
    $('.quant-form').submit(function () {
        if (page == 'record') {
            var formId = $(this).closest('form').attr('id');
            //construct the params
            urlParams = {
            };
            //distribution params
            if ($('#' + formId).find('select[name=dist]').length > 0) {
                urlParams[ 'dist'] = $('#' + formId).find('select[name=dist]').val();
            }
            if ($('#' + formId).find('input[name=type]').length > 0) {
                urlParams[ 'type'] = $('#' + formId).find('input[name=type]').val();
            }
            
            //metrical analysis params
            if ($('#' + formId + ' select[name=measurement]').length > 0) {
                urlParams[ 'measurement'] = $('#' + formId).find('select[name=measurement]').val();
            }
            if ($('#' + formId).children('input[name=from]').length > 0) {
                urlParams[ 'from'] = $('#' + formId).children('input[name=from]').val();
            }
            if ($('#' + formId).children('input[name=to]').length > 0) {
                urlParams[ 'to'] = $('#' + formId).children('input[name=to]').val();
            }
            if ($('#' + formId).children('input[name=interval]').length > 0) {
                urlParams[ 'interval'] = $('#' + formId).children('input[name=interval]').val();
            }
            
            //filter always exists within the ID page
            urlParams[ 'filter'] = $('#' + formId).children('input[name=filter]').val();
            
            //if there are compare queries
            if ($('#' + formId).children('input[name=compare]').length > 0) {
                compare = new Array();
                $('#' + formId).children('input[name=compare]').each(function () {
                    compare.push($(this).val());
                });
                urlParams[ 'compare'] = compare;
            }
            
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
            
            //set values and call chart rendering function dependent upon the id of the form
            if (formId == 'distributionForm') {
                //set bookmarkable page URL
                var href = path + 'visualize/distribution?' + params.join('&');
                $('.chart-container').children('div.control-row').children('a[title=Bookmark]').attr('href', href);
                
                //set CSV download URL
                params.push('format=csv');
                var href = path + 'apis/getDistribution?' + params.join('&');
                $('.chart-container').children('div.control-row').children('a[title=Download]').attr('href', href);
                
                //render the chart
                renderDistChart(path, urlParams);
            } else if (formId == 'metricalForm') {
                //set bookmarkable page URL
                var href = path + 'visualize/metrical?' + params.join('&');
                $('.chart-container').children('div.control-row').children('a[title=Bookmark]').attr('href', href);
                
                //set CSV download URL
                params.push('format=csv');
                var href = path + 'apis/getMetrical?' + params.join('&');
                $('.chart-container').children('div.control-row').children('a[title=Download]').attr('href', href);
                
                //render the chart
                renderMetricalChart(path, urlParams);
            }
            return false;
        }
    });
    
    /**** FORM MANIPULATION AND VALIDATION ****/
    //when clicking the add-filter link, insert a new filter template into the filter container
    $('.add-filter').click(function () {
        var container = $(this).closest('form').find('.filter-container');
        var formId = $(this).closest('form').attr('id');
        var type = $('#type').text();
        if (type.indexOf('foaf') >= 0) {
            type = 'foaf:Person|foaf:Organization';
        }
        $('#field-template').clone().removeAttr('id').appendTo(container);
        //work on removing the option for the current class
        $('.filter-container').find('option[type="' + type + '"]').remove();
        validate(formId);
        return false;
    });
    
    $('#getDateRange').click(function () {
        var formId = $(this).closest('form').attr('id');
        
        //get all of the queries from the compare fields
        queries = new Array();
        $('input[name=compare]').each(function () {
            queries.push($(this).val());
        });
        
        compareParams = {
            'compare': queries
        }
        
        //show ajax gif
        $('.getDateRange-container').children('span').removeClass('hidden');
        
        //call the getDateRange API to find the absolute earliest and latest dates across all queries
        $.get(path + 'apis/getDateRange', $.param(compareParams, true),
        function (data) {
            //set text inputs
            $('#fromYear').val(Math.abs(data.earliest));
            $('#toYear').val(Math.abs(data.latest));
            
            //set era drop downs
            if (data.earliest < 0) {
                $('#fromEra').val('bc');
            } else {
                $('#fromEra').val('ad');
            }
            
            if (data.latest < 0) {
                $('#toEra').val('bc');
            } else {
                $('#toEra').val('ad');
            }
            
            //automatically set the interval, if blank
            if (isNaN($('#interval').val())) {
                $('#interval').val(5)
            }
            
            $('.getDateRange-container').children('span').addClass('hidden');
            
            //revalidate form
            validate(formId);
        });
        
        return false;
    });
    
    //observe changes in drop down menus for validation
    $('#categorySelect').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    $('#measurementSelect').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //monitor changes from quantitative analysis drop down menus to execute ajax calls
    $('.filter-container').on('change', '.filter .add-filter-prop', function () {
        var prop = $(this).val();
        var type = $(this).children('option:selected').attr('type');
        var next = $(this).next('.prop-container');
        
        var q = new Array();
        q.push($('#base-query').text());
        //get the filter query from previous parameters
        $(this).parent('.filter').prevAll('.filter').each(function () {
            pair = parseFilter($(this));
            if (pair.length > 0) {
                q.push(pair);
            }
        });
        filter = q.join('; ');
        
        //if the prop is a from or do date, insert date entry template, otherwise get facets from SPARQL
        if (prop == 'from' || prop == 'to') {
            addDate(next);
        } else {
            getFacets(filter, prop, type, next, path, urlParams[ 'lang']);
        }
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates($(this).closest('.filter-container'));
        if (duplicates == true) {
            $(this).closest('.filter-container').children('.duplicate-date-alert').removeClass('hidden');
        } else {
            $(this).closest('.filter-container').children('.duplicate-date-alert').addClass('hidden');
        }
    });
    
    $('.filter-container').on('change', '.filter .prop-container .add-filter-object', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //validate on date change
    $('.filter-container').on('change', '.filter .prop-container span input.year', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('.filter-container').on('change', '.filter .prop-container span select.era', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //validate on measurement analysis date range changes
    $('#fromYear').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#fromEra').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#toYear').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#toEra').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#interval').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //delete the compare/filter query pair
    $('.filter-container').on('click', '.filter .control-container .remove-query', function () {
        var container = $(this).closest('.filter-container');
        var formId = $(this).closest('form').attr('id');
        $(this).closest('.filter').remove();
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates(container);
        if (duplicates == true) {
            container.children('.duplicate-date-alert').removeClass('hidden');
        } else {
            container.children('.duplicate-date-alert').addClass('hidden');
        }
        
        validate(formId);
        return false;
    });
    
    //on page load, populate the SPARQL-based query filters
    $('.quant-form').find('.filter').each(function () {
        var formId = $(this).closest('form').attr('id');
        var prop = $(this).children('.add-filter-prop').val();
        var type = $(this).children('.add-filter-prop').children('option:selected').attr('type');
        var next = $(this).children('.add-filter-prop').next('.prop-container');
        
        if (next.children('span.filter').text().length > 0) {
            var filter = next.children('span.filter').text();
        } else {
            var filter = '';
        }
        
        if (prop == 'from' || prop == 'to') {
            validate(formId);
        } else if (prop == 'nmo:hasTypeSeriesItem') {
            validate(formId);
        } else {
            getFacets(filter, prop, type, next, path, urlParams[ 'lang']);
        }
    });
    
    /***COMPARE***/
    //add dataset for comparison
    $('.add-compare').click(function () {
        var container = $(this).closest('form').find('.compare-master-container');
        var formId = $(this).closest('form').attr('id');
        $('#compare-container-template').clone().removeAttr('id').appendTo(container);
        
        //automatically insert a property-object query pair
        $('#field-template').clone().removeAttr('id').appendTo('.compare-master-container .compare-container:last');
        validate(formId);
        return false;
    });
    //add property-object facet into dataset
    $('.compare-master-container').on('click', 'h4 small .add-compare-field', function () {
        $('#field-template').clone().removeAttr('id').appendTo($(this).closest('.compare-container'));
        var formId = $(this).closest('form').attr('id');
        validate(formId);
        
        var count = $(this).closest('.compare-container').children('.filter').length;
        
        //toggle the alert box when there aren't any filters
        if (count > 0) {
            $(this).closest('.compare-container').children('.empty-query-alert').addClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.empty-query-alert').removeClass('hidden');
        }
        
        return false;
    });
    
    //get facets on property drop-down list change
    $('.compare-master-container').on('change', '.compare-container .filter .add-filter-prop', function () {
        var prop = $(this).val();
        var type = $(this).children('option:selected').attr('type');
        var next = $(this).next('.prop-container');
        
        var q = new Array();
        //get the filter query from previous parameters
        $(this).parent('.filter').prevAll('.filter').each(function () {
            pair = parseFilter($(this));
            if (pair.length > 0) {
                q.push(pair);
            }
        });
        filter = q.join('; ');
        //if the prop is a from or do date, insert date entry template, otherwise get facets from SPARQL
        if (prop == 'from' || prop == 'to') {
            addDate(next);
        } else {
            getFacets(filter, prop, type, next, path, urlParams[ 'lang']);
        }
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates($(this).closest('.compare-container'));
        if (duplicates == true) {
            $(this).closest('.compare-container').children('.duplicate-date-alert').removeClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.duplicate-date-alert').addClass('hidden');
        }
    });
    
    //validate on object drop-down list change
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container .add-filter-object', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //delete dataset query
    $('.compare-master-container').on('click', '.compare-container h4 small .remove-dataset', function () {
        var formId = $(this).closest('form').attr('id');
        $(this).closest('.compare-container').remove();
        validate(formId);
        return false;
    });
    
    //delete property-object pair
    $('.compare-master-container').on('click', '.compare-container .filter .control-container .remove-query', function () {
        var formId = $(this).closest('form').attr('id');
        var count = $(this).closest('.compare-container').children('.filter').length;
        
        //toggle the alert box when there aren't any filters
        if (count == 1) {
            $(this).closest('.compare-container').children('.empty-query-alert').removeClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.empty-query-alert').addClass('hidden');
        }
        
        //store the container object to processing after deletion of filter
        var container = $(this).closest('.compare-container');
        $(this).closest('.filter').remove();
        
        //display duplicate property alert if there is more than one from or to date. must count after deletion of filter
        duplicates = countDates(container);
        if (duplicates == true) {
            container.children('.duplicate-date-alert').removeClass('hidden');
        } else {
            container.children('.duplicate-date-alert').addClass('hidden');
        }
        validate(formId);
        return false;
    });
    
    //validate on date change
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container span input.year', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container span select.era', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
});

function parseFilter(container) {
    var pair;
    
    //only generate filter if both the property and object have values
    if (container.children('.add-filter-prop').val().length > 0) {
        //evaluate dates vs. facets
        if (container.children('.add-filter-prop').val() == 'to' || container.children('.add-filter-prop').val() == 'from') {
            var year = container.children('.prop-container').children('span').children('input.year').val();
            var era = container.children('.prop-container').children('span').children('select.era').val();
            
            if (era == 'bc') {
                year = year * -1;
            }
            
            pair = container.children('.add-filter-prop').val() + ' ' + year;
        } else if (container.children('.add-filter-prop').val() && container.children('.prop-container').children('.add-filter-object').val()) {
            pair = container.children('.add-filter-prop').val() + ' ' + container.children('.prop-container').children('.add-filter-object').val();
        }
    }
    
    return pair;
}

function generateFilter(formId) {
    var q = new Array($('#base-query').text());
    //iterate through additional features
    $('#' + formId).find('.filter-container .filter').each(function () {
        //evaluate dates vs. facets
        if ($(this).children('.add-filter-prop').val() == 'to' || $(this).children('.add-filter-prop').val() == 'from') {
            var year = $(this).children('.prop-container').children('span').children('input.year').val();
            var era = $(this).children('.prop-container').children('span').children('select.era').val();
            
            if (era == 'bc') {
                year = year * -1;
            }
            q.push($(this).children('.add-filter-prop').val() + ' ' + year);
        } else if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
            q.push($(this).children('.add-filter-prop').val() + ' ' + $(this).children('.prop-container').children('.add-filter-object').val());
        }
    });
    
    query = q.join('; ');
    return query;
}

//count occurrences of from and to date query fields to display error warning or negate query validation
function countDates(self) {
    var toCount = 0;
    var fromCount = 0;
    self.siblings().addBack().children('.filter').children('.add-filter-prop').each(function () {
        if ($(this).val() == 'to') {
            toCount++;
        } else if ($(this).val() == 'from') {
            fromCount++;
        }
    });
    
    if (fromCount > 1 || toCount > 1) {
        return true;
    } else {
        return false;
    }
}

//insert the from/to date template
function addDate(next) {
    template = $('#date-container-template').clone().removeAttr('id');
    var formId = $(next).closest('form').attr('id');
    next.html(template);
    validate(formId);
}

//get the associated facets from thet getSparqlFacets web service
function getFacets(filter, prop, type, next, path, lang) {
    var formId = $(next).closest('form').attr('id');
    if (type != null) {
        //define ajax parameters
        params = {
            "facet": prop,
            "lang": lang
        }
        
        params.filter = filter;
        
        //add query, if available (prepopulating facet drop down menus)
        if (next.children('span.query').text().length > 0) {
            params.query = next.children('span.query').text();
        }
        
        //set ajax loader
        loader = $('#ajax-loader-template').clone().removeAttr('id');
        next.html(loader);
        
        $.get(path + 'ajax/getSparqlFacets', params,
        function (data) {
            next.html(data);
            validate(formId);
        });
    } else {
        next.children('.add-filter-object').remove();
        validate(formId);
    }
}

function validate(formId) {
    var page = $('#page').text();
    var elements = new Array();
    //evaluate each portion of the form
    
    //ensure category drop down contains a value, but only for the distribution page
    if (formId == 'distributionForm') {
        if ($('#categorySelect').val()) {
            elements.push(true);
        } else {
            elements.push(false);
        }
    } else if (formId == 'metricalForm') {
        if ($('#measurementSelect').val()) {
            elements.push(true);
        } else {
            elements.push(false);
        }
    }
    
    //evaluate the filter from record page
    if ($('#' + formId).find('.filter-container').length > 0) {
        $('#' + formId + ' .filter').each(function () {
            if ($(this).children('.add-filter-prop').val() == 'to' || $(this).children('.add-filter-prop').val() == 'from') {
                var year = $(this).children('.prop-container').children('span').children('input.year').val();
                if ($.isNumeric(year)) {
                    elements.push(true);
                } else {
                    elements.push(false);
                }
            } else {
                if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
                    elements.push(true);
                } else {
                    elements.push(false);
                }
            }
        });
    }
    //evaluate every compare query
    $('#' + formId + ' .compare-master-container .compare-container').each(function () {
        //look for duplicate from or to dates
        duplicates = countDates($(this));
        if (duplicates == true) {
            elements.push(false);
        }
        
        //if there are no filters in the compare container, then the compare query is false
        if ($(this).children('.filter').length > 0) {
            $(this).children('.filter').each(function () {
                //if the prop is to for from, then validate the integer
                if ($(this).children('.add-filter-prop').val() == 'to' || $(this).children('.add-filter-prop').val() == 'from') {
                    var year = $(this).children('.prop-container').children('span').children('input.year').val();
                    if ($.isNumeric(year)) {
                        elements.push(true);
                    } else {
                        elements.push(false);
                    }
                } else if ($(this).children('.add-filter-prop').val() == 'nmo:hasTypeSeriesItem') {
                    if ($(this).children('.prop-container').children('span').children('input.coinType').val()) {
                        elements.push(true);
                    } else {
                        elements.push(false);
                    }
                } else {
                    //otherwise check for value of the object drop-down menu
                    if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
                        elements.push(true);
                    } else {
                        elements.push(false);
                    }
                }
            });
        } else {
            elements.push(false);
        }
    });
    
    //validate date range query for measurement analysis, only validate if there is a value in one or more relevant elements
    if ($('#' + formId + ' #measurementRange-container').length > 0) {
        var fromYear = $('#fromYear').val();
        var toYear = $('#toYear').val();
        var interval = $('#interval').val();
        
        //check to see if any values have been set
        if ($.isNumeric(fromYear) || $.isNumeric(toYear) || $.isNumeric(interval)) {
            //if they are all numeric values, then the controls are valid
            if ($.isNumeric(fromYear) && $.isNumeric(toYear) && $.isNumeric(interval)) {
                if (fromYear > 0 && toYear > 0) {
                    //be sure that fromYear is less than toYear
                    if ($('#fromEra').val() == 'bc') {
                        fromYear = fromYear * -1;
                    }
                    if ($('#toEra').val() == 'bc') {
                        toYear = toYear * -1;
                    }
                    
                    //be sure that fromYear is less than toYear
                    if (fromYear >= toYear) {
                        elements.push(false);
                        $('.measurementRange-alert').removeClass('hidden');
                    } else {
                        elements.push(true);
                        $('.measurementRange-alert').addClass('hidden');
                    }
                    
                    //evaluate the interval and only allow the interval of 1 year for a range of <= 30 years
                    if (interval == 1) {
                        if (toYear - fromYear > 30) {
                            elements.push(false);
                            $('.interval-alert').removeClass('hidden');
                        } else {
                            elements.push(true);
                            $('.interval-alert').addClass('hidden');
                        }
                    } else {
                        $('.interval-alert').addClass('hidden');
                    }
                } else {
                    elements.push(false);
                    $('.measurementRange-alert').removeClass('hidden');
                }
            } else {
                elements.push(false);
                $('.measurementRange-alert').removeClass('hidden');
            }
        } else {
            //hide the date alert if no values have been set
            $('.measurementRange-alert').addClass('hidden');
            $('.interval-alert').addClass('hidden');
        }
    }
    
    //if there is a false element to the form OR if there is only one element (i.e., the category), then the form is invalid
    if (elements.indexOf(false) !== -1) {
        var valid = false;
    } else {
        if (page == 'page') {
            //there must be at least one compare container on the analsyis page
            if ($('#' + formId + ' .compare-master-container .compare-container').length >= 1) {
                var valid = true;
            } else {
                var valid = false;
            }
        } else {
            var valid = true;
        }
    }
    
    //enable/disable button
    if (valid == true) {
        //generate the filter query and assign the value to the hidden input
        q = generateFilter(formId);
        $('#' + formId + ' input[name=filter]').val(q);
        
        //for each comparison query, insert an input, but clear input[name=compare] first
        $('#' + formId).find('input[name=compare]').remove();
        $('#' + formId + ' .compare-master-container .compare-container').each(function () {
            var q = new Array();
            $(this).children('.filter').each(function () {
                //evaluate dates vs. facets
                if ($(this).children('.add-filter-prop').val() == 'to' || $(this).children('.add-filter-prop').val() == 'from') {
                    var year = $(this).children('.prop-container').children('span').children('input.year').val();
                    var era = $(this).children('.prop-container').children('span').children('select.era').val();
                    
                    if (era == 'bc') {
                        year = year * -1;
                    }
                    
                    q.push($(this).children('.add-filter-prop').val() + ' ' + year);
                } else if ($(this).children('.add-filter-prop').val() == 'nmo:hasTypeSeriesItem') {
                    //create query for coinType
                    q.push($(this).children('.add-filter-prop').val() + ' ' + $(this).children('.prop-container').children('span').children('input.coinType').val());
                } else if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
                    q.push($(this).children('.add-filter-prop').val() + ' ' + $(this).children('.prop-container').children('.add-filter-object').val());
                }
            });
            query = q.join('; ');
            $('#' + formId).append('<input name="compare" type="hidden" value="' + query + '">');
        });
        
        //insert inputs for measurementRange query
        if ($('#' + formId + ' #measurementRange-container').length > 0) {
            if ($.isNumeric($('#fromYear').val()) && $.isNumeric($('#toYear').val()) && $.isNumeric($('#interval').val())) {
                var fromYear = $('#fromYear').val();
                var toYear = $('#toYear').val();
                var interval = $('#interval').val();
                
                if ($('#fromEra').val() == 'bc') {
                    fromYear = fromYear * -1;
                }
                if ($('#toEra').val() == 'bc') {
                    toYear = toYear * -1;
                }
                //delete existing inputs
                $('#' + formId).children('input[name=from]').remove();
                $('#' + formId).children('input[name=to]').remove();
                $('#' + formId).children('input[name=interval]').remove();
                
                //insert new inputs
                $('#' + formId).append('<input name="from" type="hidden" value="' + fromYear + '">');
                $('#' + formId).append('<input name="to" type="hidden" value="' + toYear + '">');
                $('#' + formId).append('<input name="interval" type="hidden" value="' + interval + '">');
            } else {
                $('#' + formId).children('input[name=from]').remove();
                $('#' + formId).children('input[name=to]').remove();
                $('#' + formId).children('input[name=interval]').remove();
            }
        }
        
        //enable the button
        $('#' + formId).children('.visualize-submit').prop("disabled", false);
        
        //show the button to automatically generate the date range for the given queries.
        $('.getDateRange-container').removeClass('hidden');
    } else {
        $('#' + formId).children('.visualize-submit').prop("disabled", true);
        $('.getDateRange-container').addClass('hidden');
    }
}

function renderDistChart(path, urlParams) {
    $('#distribution .chart-container').removeClass('hidden');
    $('#distribution-chart').html('');
    $('#distribution-chart').height(600);
    
    if (urlParams[ 'dist'].indexOf('nmo:has') != -1) {
        var distValue = urlParams[ 'dist'].replace('nmo:has', '').toLowerCase();
    } else {
        var distValue = urlParams[ 'dist'];
    }
    var distLabel = $('select[name=dist] option:selected').text();
    
    if (urlParams[ 'type'] == 'count') {
        var y = 'count';
    } else {
        var y = 'percentage';
    }
    
    $.get(path + 'apis/getDistribution', $.param(urlParams, true),
    function (data) {
        new d3plus.BarChart().data(data).groupBy('subset').x(distValue).y(y).tooltipConfig({
                title: function (d) {
                    return d['subset'];
                },
                tbody:[[function (d) {
                    return y + ': ' + d[y] + (y == 'percentage' ? '%' : '')
                }]]
            }).select("#distribution-chart").render();
    });
}

function renderMetricalChart(path, urlParams) {
    $('#metrical .chart-container').removeClass('hidden');
    $('#metrical-chart').html('');
    $('#metrical-chart').height(600);
    
    if ($.isNumeric(urlParams[ 'interval'])) {
        $.get(path + 'apis/getMetrical', $.param(urlParams, true),
        function (data) {
            new d3plus.LinePlot().data(data).baseline(0).groupBy("subset").x('value').y('average').shapeConfig({
                Line: {
                    strokeWidth: 2
                }
            }).tooltipConfig({
                title: function (d) {
                    return d["label"];
                },
                tbody:[[function (d) {
                    return "Average: " + d[ "average"]
                }]]
            }).select("#metrical-chart").render();
        });
    } else {
        $.get(path + 'apis/getMetrical', $.param(urlParams, true),
        function (data) {
            new d3plus.BarChart().data(data).groupBy('subset').x('value').y('average').tooltipConfig({
                title: function (d) {
                    return d["subset"];
                },
                tbody:[[function (d) {
                    return "Average: " + d[ "average"]
                }]]
            }).select("#metrical-chart").render();
        });
    }
}