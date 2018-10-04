/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Render IIIF images for physical coin records
 ************************************/
$(document).ready(function () {
    
    //add obverse IIIF image
    var obvInfo = $('#obv-iiif-service').text() + '/info.json';
    var obverseIIIF = L.map('obv-iiif-container', {
        center:[0, 0],
        crs: L.CRS.Simple,
        zoom: 0
    });
    
    L.tileLayer.iiif(obvInfo).addTo(obverseIIIF);    
    
     //add reverse IIIF image
      var revInfo = $('#rev-iiif-service').text() + '/info.json';
      var reverseIIIF = L.map('rev-iiif-container', {
        center:[0, 0],
        crs: L.CRS.Simple,
        zoom: 0
    });
    
    L.tileLayer.iiif(revInfo).addTo(reverseIIIF); 
});