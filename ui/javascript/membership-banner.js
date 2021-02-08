/* Date: March 2020
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

    if (!sessionStorage.alreadyClicked) {
        $(template).insertBefore('.navbar').css('background-color', bgcolor);
        sessionStorage.alreadyClicked = 1;
    }
    
    $('#membership-banner').find('button.close').click(function(){
        $('#membership-banner').fadeOut();
    });
});