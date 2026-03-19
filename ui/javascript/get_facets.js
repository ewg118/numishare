/************************************
GET FACET TERMS IN RESULTS PAGE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This utilizes ajax to populate the list of terms in the facet category in the results page.
If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
 ************************************/
$(document).ready(function () {
    var popupStatus = 0;
    var pipeline = 'results';
    var langStr = getURLParameter('lang');
    if (langStr == 'null') {
        var lang = '';
    } else {
        var lang = langStr;
    }
    
    //set hierarchical labels on load
    $('.hierarchical-facet').each(function () {
        var field = $(this).attr('id').split('_hier')[0];
        var title = $(this).attr('title');
        hierarchyLabel(field, title);
    });
    
    if ($('#century_num').length > 0) {
        if ($('#century_num-list').html().indexOf('<li') > 0) {
            dateLabel();
        }
    }
    
    $("#backgroundPopup").on('click', function (event) {
        disablePopup();
    });
    
    //multiselect facets
    $('.multiselect').multiselect({
        buttonWidth: '250px',
        enableCaseInsensitiveFiltering: true,
        maxHeight: 250,
        enableHTML: true,
        buttonText: function (options, select) {
            if (options.length == 0) {
                return select.attr('title');
            } else if (options.length > 2) {
                return select.attr('title') + ': ' + options.length;
            } else {
                var selected = '';
                options.each(function () {
                    var val = $(this).text();
                    //if there is an img in the label, then parse the HTML and display only the label
                    if (val.indexOf('<img') >= 0) {
                        var el = $('<div></div>');
                        el.html(val);
                        selected += el.text().trim() + ', ';
                    } else {
                        selected += $(this).text() + ', ';
                    }
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
                if (q.length > 0) {
                    var category = id.split('-select')[0];
                    var mincount = $(this).attr('mincount');
                    $.get('get_facet_options', {
                        q: q, category: category, mincount: mincount, lang: lang, pipeline: 'results'
                    },
                    function (data) {
                        $('#ajax-temp').html(data);
                        $('#' + id).html('');
                        $('#' + id).attr('new_query', '');
                        $('#ajax-temp option').each(function () {
                            $(this).clone().appendTo('#' + id);
                        });
                        $('#' + id).multiselect('rebuild');
                    });
                }
            }
        }
    });
    
    //on open
    $('button.multiselect').on('click', function () {
        var q = getQuery();
        var id = $(this).parent('div').prev('select').attr('id');
        var category = id.split('-select')[0];
        var mincount = $(this).parent('div').prev('select').attr('mincount');
        $.get('get_facet_options', {
            q: q, category: category, mincount: mincount, lang: lang, pipeline: 'results'
        },
        function (data) {
            $('#ajax-temp').html(data);
            $('#' + id).html('');
            $('#' + id).attr('new_query', '');
            $('#ajax-temp option').each(function () {
                $(this).clone().appendTo('#' + id);
            });
            $('#' + id).multiselect('rebuild');
        });
    });
    
    /***** SEARCH *****/
    $('#search_button').click(function () {
        var q = getQuery();
        $('#facet_form_query').attr('value', q);
    });
    
    /***************** DRILLDOWN HIERARCHICAL FACETS ********************/
    
    $('.hier-close').click(function () {
        disablePopup();
        return false;
    });
    
    $('.hierarchical-facet').click(function () {
        if (popupStatus == 0) {
            $("#backgroundPopup").fadeIn("fast");
            popupStatus = 1;
        }
        
        var q = getQuery();
        var field = $(this).attr('id').split('_hier')[0];
        var list_id = $(this).attr('id').split('-btn')[0] + '-list';
        if ($('#' + list_id).html().indexOf('<li') < 0) {
            $.get('get_hier', {
                q: q, field: field, prefix: 'L1', fq: '*', link: '', lang: lang
            },
            function (data) {
                $('#ajax-temp').html(data);
                $('#ajax-temp li').each(function () {
                    $(this).clone().appendTo('#' + list_id);
                });
            });
        }
        
        $('#' + list_id).parent('div').addClass('open');
        $('#' + list_id).show();
    });
    
    //expand category when expand/compact image pressed
    $('.hier-list').on('click', 'li .expand_category', function () {
        var fq = $(this).next('input').val();
        var list = $(this).attr('id').split('__')[0].split('/')[1] + '__list';
        var field = $(this).attr('field');
        var prefix = $(this).attr('next-prefix');
        var q = getQuery();
        var section = $(this).attr('section');
        var link = $(this).attr('link');
        
        if ($(this).attr('class').indexOf('minus') > 0) {
            $(this).removeClass('glyphicon-minus');
            $(this).addClass('glyphicon-plus');
            $('#' + list).hide();
        } else {
            $(this).removeClass('glyphicon-plus');
            $(this).addClass('glyphicon-minus');
            //perform ajax load on first click of expand button
            if ($(this).parent('li').children('ul').html().indexOf('<li') < 0) {
                $.get('get_hier', {
                    q: q, field: field, prefix: prefix, fq: '"' + fq + '"', link: link, section: section, lang: lang
                },
                function (data) {
                    $('#ajax-temp').html(data);
                    $('#ajax-temp li').each(function () {
                        $(this).clone().appendTo('#' + list);
                    });
                });
            }
            $('#' + list).show();
        }
    });
    
    //remove all ancestor or descendent checks on uncheck
    $('.hier-list').on('click', 'li input', function () {
        var field = $(this).attr('field');
        var title = $(this).closest('#' + field + '_hier-list').prev('button').attr('title');
        
        var count_checked = 0;
        $('#' + field + '_hier-list input:checked').each(function () {
            count_checked++;
        });
        
        if (count_checked > 0) {
            hierarchyLabel(field, title);
        } else {
            $('#' + field + '_hier-btn').children('span').text(title);
        }
    });
    
    /***************** DRILLDOWN FOR DATES ********************/
    
    $('.century-close').on('click', function (event) {
        disablePopup();
        return false;
    });
    
    $('#century_num_link').on('click', function (event) {
        if (popupStatus == 0) {
            $("#backgroundPopup").fadeIn("fast");
            popupStatus = 1;
        }
        
        q = getQuery();
        var list_id = $(this).attr('id').split('_link')[0] + '-list';
        if ($('#' + list_id).html().indexOf('<li') < 0) {
            $.get('get_centuries', {
                q: q
            },
            function (data) {
                $('#ajax-temp').html(data);
                $('#ajax-temp li').each(function () {
                    $(this).clone().appendTo('#' + list_id);
                });
            });
        }
        
        $('#' + list_id).parent('div').addClass('open');
        $('#' + list_id).show();
    });
    
    $('#century_num-list').on('click', 'li .expand_century', function () {
        var century = $(this).attr('century');
        var q = getQuery();
        //hide list if it is expanded
        if ($(this).attr('class').indexOf('minus') > 0) {
            $(this).removeClass('glyphicon-minus');
            $(this).addClass('glyphicon-plus');
            $('#century_' + century + '_list').hide();
        } else {
            $(this).removeClass('glyphicon-plus');
            $(this).addClass('glyphicon-minus');
            //perform ajax load on first click of expand button
            if ($(this).parent('li').children('ul').html().indexOf('<li') < 0) {
                $.get('get_decades', {
                    q: q, century: century
                },
                function (data) {
                    $('#ajax-temp').html(data);
                    $('#ajax-temp li').each(function () {
                        $(this).clone().appendTo('#century_' + century + '_list');
                    });
                });
            }
            $('#century_' + century + '_list').show();
        }
    });
    
    //check parent century box when a decade box is checked
    $('#century_num-list').on('click', 'li ul li .decade_checkbox', function () {
        if ($(this).is(':checked')) {
            $(this).parent('li').parent('ul').parent('li').children('input').attr('checked', true);
        }
        //set label
        dateLabel();
    });
    //uncheck child decades when century is unchecked
    $('#century_num-list').on('click', 'li .century_checkbox', function () {
        if ($(this).not(':checked')) {
            $(this).parent('li').children('ul').children('li').children('.decade_checkbox').attr('checked', false);
        }
        //set label
        dateLabel();
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
            $('#century_num-list').parent('div').removeClass('open');
            $('#findspot_hier-list').parent('div').removeClass('open');
            $('#category_hier-list').parent('div').removeClass('open');
            $('#region_hier-list').parent('div').removeClass('open');
            
            popupStatus = 0;
        }
    }
    
    
    function getURLParameter(name) {
        return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
    }
});