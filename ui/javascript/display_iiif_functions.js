/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Render IIIF images for physical coin records
 ************************************/
$(document).ready(function () {    
    
    $('.iiif-container').each(function () {
        var service = $(this).attr('service') + '/info.json';
        var id = $(this).attr('id');
        
        var leaflet = L.map(id, {
            center:[0, 0],
            crs: L.CRS.Simple,
            zoom: 0
        });
        
        L.tileLayer.iiif(service).addTo(leaflet);
    });
});