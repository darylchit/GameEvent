toastr.options = {
    "closeButton": true,
    "timeOut": "7000",
    "extendedTimeOut": "0",
    "positionClass": "toast-top-center"
};
<% if @not_invite_confirmed_user %>
  toastr.success('You must join the roster to use this feature');
<% elsif !event.completed? %>
  toastr.success('This Feature Is Not Available Until After The Event Starts');
<% else %>
  // $('#event_not_show_user<%#= invite_not_show.user_id %>_event<%#= event.id %>').hide();
  // $('#event_rate_user<%#= invite_not_show.user_id %>_event<%#= event.id %>').hide();
  toastr.success('You have updated status as no show for invite user!');
  location.reload();
  // toastr.clear();
<% end %>
