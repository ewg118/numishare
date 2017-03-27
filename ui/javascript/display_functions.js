/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
 ************************************/
$(document).ready(function () {
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
    
    $('.iiif-image').fancybox({
        beforeShow: function () {
            var manifest = this.element.attr('manifest');
            //remove and replace #iiif-container, if different or new
            if (manifest != $('#manifest').text()) {          
                $('#iiif-container').remove();
                $(".iiif-container-template").clone().removeAttr('class').attr('id', 'iiif-container').appendTo("#iiif-window");
                $('#manifest').text(manifest);
                render_image(manifest);
            }
        },
        helpers: {
            title: {
                type: 'inside'
            }
        }
    });
    
    function render_image(manifest) {
        var iiifImage = L.map('iiif-container', {
            center:[0, 0],
            crs: L.CRS.Simple,
            zoom: 0
        });        
        
        // Grab a IIIF manifest
        $.getJSON(manifest, function (data) {       
            //determine where it is a collection or image manifest
            if (data[ '@context'] == 'http://iiif.io/api/image/2/context.json' || data['@context'] == 'http://library.stanford.edu/iiif/image-api/1.1/context.json') {
                L.tileLayer.iiif(manifest).addTo(iiifImage);
            } else if (data[ '@context'] == 'http://iiif.io/api/presentation/2/context.json') {
                var iiifLayers = {
                };
                
                // For each image create a L.TileLayer.Iiif object and add that to an object literal for the layer control
                $.each(data.sequences[0].canvases, function (_, val) {
                    iiifLayers[val.label] = L.tileLayer.iiif(val.images[0].resource.service[ '@id'] + '/info.json');
                });
                // Add layers control to the map
                L.control.layers(iiifLayers).addTo(iiifImage);
                
                // Access the first Iiif object and add it to the map
                iiifLayers[Object.keys(iiifLayers)[0]].addTo(iiifImage);
            }
        });
    }
});



// copy the base template
function gateTypeBtnClick(btn) {
    var formId = btn.closest('form').attr('id');
    
    //clone the template
    var tpl = cloneTemplate(formId);
    
    // focus the text field after select
    $(tpl).children('select').change(function () {
        $(this).siblings('input').focus();
    });
    
    // add the new template to the dom
    $(btn).parent().after(tpl);
    
    tpl.children('.removeBtn').removeAttr('style');
    tpl.children('.removeBtn').before(' |&nbsp;');
    // display the entire new template
    tpl.fadeIn('fast');
}

function cloneTemplate(formId) {
    if (formId == 'sparqlForm') {
        var tpl = $('#sparqlItemTemplate').clone();
    } else {
        var tpl = $('#searchItemTemplate').clone();
    }
    
    //remove id to avoid duplication with the template
    tpl.removeAttr('id');
    return tpl;
}