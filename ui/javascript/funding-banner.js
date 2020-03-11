/* Date: March 2020
Function: A Wikidata style funding banner loaded in the config/includes*/

$(document).ready(function () {

    var template = '<div id="funding"><div class="container">' + 
    '<div class="row"><div class="col-md-12">The new RIC Vol. II Part 3 just published by Spink & Son necessitates the replacement of about 4,000 '+ 
    'OCRE records of Hadrian. The American Numismatic Society, OCRE editor, is asking for small donations to help completing that very ' + 
    'significant improvement. If you use OCRE for teaching or research, please consider ' + 
    '<a href="https://charity.gofundme.com/o/en/campaign/updating-ocre" alt="Donate for OCRE">donating to the ANS</a>. No amount is too small.' + 
    '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div></div></div></div>';

    if (!sessionStorage.alreadyClicked) {
        $(template).insertAfter('.navbar');
        sessionStorage.alreadyClicked = 1;
    }
    
    $('#funding').find('button.close').click(function(){
        $('#funding').fadeOut();
    });
});