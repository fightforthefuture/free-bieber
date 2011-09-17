$(function() {
    $('.submit_btn').click(function(e) {
        // Validate form
        e.preventDefault();
        $('.start_hidden').show();
        $('.start_shown').hide();
        $('#id_name').focus();
    });
});
