/* Date: March 2020
Function: A Wikidata style funding banner loaded in the config/includes*/

$(document).ready(function () {

    var template = '<div id="funding"><div class="container">' + 
    '<div class="row"><div class="col-md-12">In collaboration with Spink & Son, the American Numismatic Society ' + 
    'is working to publish the new RIC Vol. II, Part 3 in OCRE. In order to help fund this labor, we asking for small donations. ' + 
    'If you use OCRE for teaching or research, please consider <a href="https://charity.gofundme.com/o/en/campaign/updating-ocre" alt="Donate for OCRE">donating to the ANS.</a>' + 
    '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div></div></div></div>';

    if (!sessionStorage.alreadyClicked) {
        $(template).insertAfter('.navbar');
        sessionStorage.alreadyClicked = 1;
    }
    
    $('#funding').find('button.close').click(function(){
        $('#funding').fadeOut();
    });
});