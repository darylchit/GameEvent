function bindGameModal() {
    var _sys = $('#user_game_system_ids');
    checkSys(_sys.val(), $('#user_game_system_ids :selected').text(), $('#user_new_game').val());

    _sys.change(function() {
        checkSys($('#user_game_system_ids').val(), $('#user_game_system_ids :selected').text(), $('#user_new_game').val());
        $("#add_game_form").removeError([
            "user[game_system_ids]"
        ]);
    });
}



function checkSys(id, title, game_id) {

    var request = $.ajax({
        method: "GET",
        url: "/profile/check-user-system",
        data: { sys: id, title: title, game_id: game_id },
        dataType: "script"
    });

}
$(document).ready(function() {
    $(document).on('click', '.game-card .add-icon-top', function () {
        if ($(this).parent().hasClass('add-menu-show')) {
            $('.add-menu-show').removeClass('add-menu-show');
        } else {
            $('.add-menu-show').removeClass('add-menu-show');
            $(this).parent().toggleClass('add-menu-show');
        }
    });

    $(document).on('click', '.share_btn', function () {
      $('.canceled_event_msg').html("This Event Has Been Cancelled. This Feature Is Not Accessible On This Roster");
    });
});
