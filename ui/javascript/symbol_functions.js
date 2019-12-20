$(document).ready(function () {
    $('.letter-button').click(function () {
        if ($(this).hasClass('active')) {
            $(this).removeClass('active');
        } else {
            $(this).addClass('active');
        }
    });
    
    $('#symbol-form').submit(function () {
        $('#symbol-form').children('input[type=hidden]').remove();
        
        $('.letter-button').each(function () {
            if ($(this).hasClass('active')) {
                $('#symbol-form').append('<input name="symbol" type="hidden" value="' + $(this).text() + '"/>');
            }
        });
    });
});