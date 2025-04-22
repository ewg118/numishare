/************************************
 SEARCH
 Written by Ethan Gruber, egruber@numismatics.org
 Date Modified: April 2025
 Library: jQuery
 Description: 2025 rewrite of Advanced Search for for Numishare
 ************************************/
$(document).ready(function () {
    
    //assemble query on form submission
    $('#facet_form').submit(function () {
        var q = getQuery();
        $('#facet_form_query').attr('value', q);
    });
    
    $('.addBtn').click(function () {
        var id = $(this).attr('id').replace('add-', '');
        
        //alert(id);
        
        var template = $('#' + id + '-search').clone().removeAttr('id');
        template.children('.removeBtn').removeClass('hidden');
        
        $('#' + id + '-container').append(template);
    });
    
    $('.section-container').on('click', '.form-group .removeBtn', function () {
        
        // fade out the entire template
        $(this).parent().fadeOut('fast', function () {
            $(this).remove();
        });
        return false;
    });
});