$('#my_events_actions<%= @invite.event_id %>').hide();
$('.modal-backdrop').hide();
<% if @invite.present?%>
    toastr.options = {
        "closeButton": true,
        "timeOut": "7000",
        "extendedTimeOut": "0",
        "positionClass": "toast-top-center"
    };
    toastr.success('You Have Been Removed From This Event');
    location.reload();
<% if false %>
  $('.event_action<%= event.id %>').html('Join');
  $('.event_action<%= event.id %>').attr("href", "/game_rosters/<%= event.id %>/invites/");
  $('.event_action<%= event.id %>').data("method","post");
  <% spot = event.get_spot%>
  $('.spot<%= event.id %>').html('<%= spot %>');

  <% if invitations.present? %>
    $('#invitations_mobile').html("<%= escape_javascript render(:partial => 'my_events/invitation_list_mobile', collection: invitations, as: :event, locals: { invitation: true })%>")
    $('#invitations_desktop').html("<%= escape_javascript render(:partial => 'my_events/event_list_desktop', collection: invitations, as: :event, locals: { invitation: true })%>")
  <% else %>
    $('#invitations_mobile').html('<div class="video_icon"><i class="fa fa-frown-o" aria-hidden="true"></i></div><h3 class="text-center"> Invitations not found </h3>')
    $('#invitations_desktop').html('<li><div class="video_icon"><i class="fa fa-frown-o" aria-hidden="true"></i></div><h3 class="text-center"> Invitations not found </h3></li>')
  <% end %>
  <% if upcoming_events.present? %>
    $('#upcoming_events_mobile').html("<%= escape_javascript render(:partial => 'my_events/my_upcoming_events_mobile' , collection: upcoming_events, as: :event, locals: { invitation: false })%>")
    $('#upcoming_events_desktop').html("<%= escape_javascript render(:partial => 'my_events/event_list_desktop' , collection: upcoming_events, as: :event, locals: { invitation: false })%>")
  <% else %>
    $('#upcoming_events_mobile').html('<div class="video_icon"><i class="fa fa-frown-o" aria-hidden="true"></i></div><h3 class="text-center"> Upcoming Events not found </h3>')
    $('#upcoming_events_desktop').html('<li><div class="video_icon"><i class="fa fa-frown-o" aria-hidden="true"></i></div><h3 class="text-center"> Upcoming Events not found </h3></li>')
  <% end %>
  // $('invitations_count').html('<%= invitations.count %>')
  // $('upcoming_events_count').html('<%= invitations.count %>')
  // toastr.clear();
 <% end %>
<% else %>

<% end %>
