<% if @invite_removed %>
  $('.remove_player<%= @invite_removed_id %>').remove();
  <% spot = event.get_spot %>

  toastr.options = {
      "closeButton": true,
      "timeOut": "7000",
      "extendedTimeOut": "0",
      "positionClass": "toast-top-center"
  };
  toastr.success('You have removed player from an event!');
  // toastr.clear();
  location.reload();
<% else %>

<% end %>
$('.modal-backdrop').hide();
