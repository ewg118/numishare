/* Date: February 2021
Function: A Wikidata style funding banner loaded in the config/includes*/

$(document).ready(function () {
    
    var template = '<div id="membership-banner"><div class="container">' +
    '<div class="row" style="height:100px;position:relative">' +
    '<div class="col-md-2 text-center"><a href="http://numismatics.org/membership/"><img src="http://numismatics.org/themes/ocre/images/ans-logo-inverse.png" alt="ANS Logo" style="max-width:100px"/></a></div>' +
    '<div class="col-md-10 hidden-sm hidden-xs text-center" style="top:50%; font-size:20px"><a href="http://numismatics.org/membership/">Support this resource by joining the American Numismatic ' +
    'Society as a member today!</a><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button></div>' +
    '<div class="col-md-10 visible-sm visible-xs text-center" style="font-size:16px"><a href="http://numismatics.org/membership/">Support this resource by joining the American Numismatic Society as a member today!</a>' +
    '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button></div>' +
    '</div></div></div>';
    
    var bgcolor = $('.navbar').css('background-color');
    
    if (! sessionStorage.alreadyClicked) {
        if (lightOrDark(bgcolor) == 'light') {
            bgcolor = '#000000';
        }
        $(template).insertBefore('.navbar').css('background-color', bgcolor);
        sessionStorage.alreadyClicked = 1;
    }
    
    $('#membership-banner').find('button.close').click(function () {
        $('#membership-banner').fadeOut();
    });
});

/*** lightOrDark function from https://awik.io/determine-color-bright-dark-using-javascript/ ***/
function lightOrDark(color) {
    
    // Variables for red, green, blue values
    var r, g, b, hsp;
    
    // Check the format of the color, HEX or RGB?
    if (color.match(/^rgb/)) {
        
        // If RGB --> store the red, green, blue values in separate variables
        color = color.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+(?:\.\d+)?))?\)$/);
        
        r = color[1];
        g = color[2];
        b = color[3];
    } else {
        
        // If hex --> Convert it to RGB: http://gist.github.com/983661
        color = +("0x" + color.slice(1).replace(
        color.length < 5 && /./g, '$&$&'));
        
        r = color >> 16;
        g = color >> 8 & 255;
        b = color & 255;
    }
    
    // HSP (Highly Sensitive Poo) equation from http://alienryderflex.com/hsp.html
    hsp = Math.sqrt(
    0.299 * (r * r) +
    0.587 * (g * g) +
    0.114 * (b * b));
    
    // Using the HSP value, determine whether the color is light or dark
    if (hsp > 127.5) {
        
        return 'light';
    } else {
        
        return 'dark';
    }
}