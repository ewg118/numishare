/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Date: May 2020
Library: jQuery
Description: Display functions for coin type records. Extended 2020 for displaying images of physical coins connected to hoards
 ************************************/
$(document).ready(function () {

    //display the magnifying glass glyph when hovering the mouse of divs that contain it (for IIIF)
    $('.g_doc:has(.iiif-zoom-glyph)').hover(function () {
        $(this).find('.iiif-zoom-glyph').fadeIn();
    },
    function () {
        $(this).find('.iiif-zoom-glyph').fadeOut();
    });

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
            this.title = '<a href="' + this.element.attr('id') + '">' + this.element.attr('title') + '</a>'
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
    
        
    $('.model-button').fancybox({
         beforeShow: function () {
            var url = this.element.attr('model-url');
            this.title = '<a href="' + this.element.attr('identifier') + '">' + this.element.attr('title') + '</a>';
            //if the URL is sketchfab, then remove existing iframe and reload iframe
            if (url.indexOf('sketchfab') > 0) {          
                $('#model-window').children('iframe').remove();
                $("#model-iframe-template").clone().removeAttr('id').attr('src', url + '/embed').appendTo("#model-window");
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