/*******************
AUTHOR: Ethan Gruber
DATE: June 2020
FUNCTIONS USED IN FACET-BASED PAGES: BROWSE, COLLECTION, AND MAPS
 ********************/
 
function getQuery() {
    //get categories
    query = new Array();
    var collection_type = $('#collection_type').text();
    
    //get non-facet fields that may have been passed from search
    var query_terms = $('#facet_form_query').attr('value').split(' AND ');
    var non_facet_terms = new Array();
    for (i in query_terms) {
        if (query_terms[i].indexOf('_facet') < 0 && query_terms[i].indexOf('dob_num') < 0 && query_terms[i].indexOf('taq_num') < 0 && query_terms[i] != '*:*' && query_terms[i].indexOf('typeNumber') < 0) {
            non_facet_terms.push(query_terms[i]);
        }
    }
    if (non_facet_terms.length > 0) {
        query.push(non_facet_terms.join(' AND '));
    }
    
    //hierarchical facets
    $('.hier-list').each(function () {
        var field = $(this).attr('id').split('-list')[0];
        var categories = new Array();
        $(this).find('input:checked').each(function () {
            if ($(this).parent('li').html().indexOf('category_level') < 0 || $(this).parent('li').children('ul').html().indexOf('<li') < 0 || $(this).parent('li').children('.category_level').find('input:checked').length == 0) {
                segment = new Array();
                $(this).parents('li').each(function () {
                    segment.push('+"' + $(this).children('input').val() + '"');
                });
                var joined = field + ':(' + segment.join(' ') + ')';
                categories.push(joined);
            }
        });
        //if the categories array is not null, establish the category query string
        if (categories.length > 0) {
            if (categories.length > 1) {
                query.push('(' + categories.join(' OR ') + ')');
            } else {
                query.push(categories[0]);
            }
        }
    });
    
    //get century/decades
    var date = getDate();
    if (date.length > 0) {
        query.push(getDate());
    }
    
    //get multiselects
    $('select.multiselect').each(function () {
        var val = $(this).val();
        
        if (val != null && val.length > 0) {
            var facet = $(this).attr('id').split('-')[0];
            segments = new Array();
            for (var i = 0; i < val.length; i++) {
                segments.push(facet + ':"' + val[i] + '"');
            }
            if (segments.length > 1) {
                if (collection_type == 'hoard' && (facet != 'taq_num' && facet != 'findspot_facet')) {
                    query.push(segments.join(' AND '));
                } else {
                    if (facet.indexOf('letter') > 0) {
                        query.push('(' + segments.join(' ') + ')');
                    } else {
                        query.push('(' + segments.join(' OR ') + ')');
                    }
                }
            } else {
                query.push(segments[0]);
            }
        }
    });
    
    //date range search
    if ($('#from_date').length > 0 || $('#to_date').length > 0) {
        if ($('#from_date').val().length > 0 || $('#to_date').val().length > 0) {
            var dateRange = getDateRange(collection_type);
            if (dateRange.length > 0) {
                query.push(dateRange);
            }
        }
    }
    
    if ($('#ah_dateRange').length > 0) {
        if ($('#ah_fromDate').val().length > 0 || $('#ah_toDate').val().length > 0) {
            var dateRange = getAhDateRange();
            if (dateRange.length > 0) {
                query.push(dateRange);
            }
        }
    }
    
    //get typeNumber
    if ($('#typeNumber').length > 0) {
        if ($('#typeNumber').val().length > 0) {
            query.push('typeNumber:' + $('#typeNumber').val());
        }
    }
    
    if ($('#imagesavailable').is(':checked')) {
        query.push('imagesavailable:true');
    }
    
    //set the value attribute of the q param to the query assembled by javascript
    if (query.length > 0) {
        return query.join(' AND ');
    } else {
        return '*:*';
    }
}

//get the date range
function getDateRange(collection_type) {
    if (collection_type == 'hoard') {
        var string = 'taq_num:';
    } else {
        var string = 'year_num:';
    }
    var from_date = $('#from_date').val().length > 0 ? $('#from_date').val(): '*';
    var from_era = $('#from_era').val() == 'minus' ? '-': '';
    
    var to_date = $('#to_date').val().length > 0 ? $('#to_date').val(): '*';
    var to_era = $('#to_era').val() == 'minus' ? '-': '';
    
    string += '[' + (from_date == '*' ? '': from_era) + from_date + ' TO ' + (to_date == '*' ? '': to_era) + to_date + ']';
    return string;
}

//get the date range for AH dates
function getAhDateRange() {
    var string = 'ah_num:';
    var from_date = $('#ah_fromDate').val().length > 0 ? $('#ah_fromDate').val(): '*';
    var to_date = $('#ah_toDate').val().length > 0 ? $('#ah_toDate').val(): '*';
    string += '[' + from_date + ' TO ' + to_date + ']';
    return string;
}

//function for assembling the Lucene syntax string for querying on centuries and decades
function getDate() {
    var date_array = new Array();
    $('.century_checkbox:checked').each(function () {
        var val = $(this).val();
        var century = 'century_num:"' + val + '"';
        var decades = new Array();
        $(this).parent('li').children('ul').children('li').children('.decade_checkbox:checked').each(function () {
            var dval = '"' + $(this).val() + '"';
            decades.push('decade_num:' + dval);
        });
        var decades_concat = '';
        if (decades.length > 1) {
            decades_concat = '(' + decades.join(' OR ') + ')';
            date_array.push(decades_concat);
        } else if (decades.length == 1) {
            date_array.push(decades[0]);
        } else {
            date_array.push(century);
        }
    });
    var date_query;
    if (date_array.length > 1) {
        date_query = '(' + date_array.join(' OR ') + ')'
    } else if (date_array.length == 1) {
        date_query = date_array[0];
    } else {
        date_query = '';
    }
    return date_query;
};

function dateLabel() {
    var title = $('#century_num_link').attr('title');
    if (title.indexOf(':') > 0) {
        title = title.split(':')[0];
    }
    dates = new Array();
    $('.century_checkbox:checked').each(function () {
        if ($(this).parent('li').children('ul').children('li').children('.decade_checkbox:checked').length == 0) {
            var century = Math.abs($(this).val());
            var suffix;
            switch (century % 10) {
                case 1:
                suffix = 'st';
                break;
                case 2:
                suffix = 'nd';
                break;
                case 3:
                suffix = 'rd';
                break;
                default:
                suffix = 'th';
            }
            label = century + suffix;
            if ($(this).val() < 0) {
                label += ' B.C.';
            }
            dates.push(label);
        }
        $(this).parent('li').children('ul').children('li').children('.decade_checkbox:checked').each(function () {
            dates.push($(this).val());
        });
    });
    
    if (dates.length > 3) {
        var date_string = title + ': ' + dates.length + ' selected';
    } else if (dates.length > 0 && dates.length <= 3) {
        var date_string = title + ': ' + dates.join(', ');
    } else if (dates.length == 0) {
        var date_string = title;
    }
    
    //set labels
    $('#century_num_link').attr('title', date_string);
    $('#century_num_link').text(date_string);
}

function hierarchyLabel(field, title) {
    categories = new Array();
    $('#' + field + '_hier-list input:checked').each(function () {
        if ($(this).parent('li').html().indexOf('category_level') < 0 || $(this).parent('li').children('ul').html().indexOf('<li') < 0 || $(this).parent('li').children('.category_level').find('input:checked').length == 0) {
            segment = new Array();
            $(this).parents('li').each(function () {
                segment.push($(this).children('input').val().split('|')[1]);
            });
            var joined = segment.reverse().join('--');
            categories.push(joined);
        }
    });
    
    if (categories.length > 0) {
        $('#' + field + '_hier-btn').children('span').text(title + ': ' + categories.length + ' selected');
    } else {
        $('#' + field + '_hier-btn').children('span').text(title);
    }
}