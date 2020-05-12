toastr.options = {
  "closeButton": true,
  "timeOut": "7000",
  "extendedTimeOut": "0",
  "positionClass": "toast-top-center"
};

$('.modal-backdrop').hide();
<%if @event_full.present? && @event_full %>
  toastr.success('This Event Is Full And Has No Waitlist!');
<% elsif  active_clan_member  %>
  toastr.success('Host Settings Do Not Allow You To Join This Event');
  $('#event_join_with_game_model').modal('hide');
<% elsif blocked_user_from_event_host.present? || blocked_user_from_event_age_limit.present? || public_preferences_validate %>
  toastr.success('Host Settings Do Not Allow You To Join This Event');
  $('#event_join_with_game_model').modal('hide');
<% elsif game_event_check %>

  $('#global_model').html("<%= j render 'add_event_game_popup' %>")
  $('#event_join_with_game_model').modal();
  var join_url = $('#event_join_form_popup').attr('action');
  $("#event_join_form_popup").validate({
    submit: {
      callback: {
        onSubmit:function(){
          $.post(join_url, $("#event_join_form_popup").serialize(),function(){},"script");
        }
      }
    }
  });
  // toastr.success('This Game Is Not In Your Library. Please Add It On Your My Account Page To Join This Event');
<% else %>
  <% if @invite.present? %>
    <% if false%>
        $('#my_events_actions<%= @invite.event_id %>').hide();
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
        $('.event_action<%= event.id %>').html('Leave');
        $('.event_action<%= event.id %>').attr("href", "/game_rosters/<%= event.id %>/invites/<%= @invite.id %>/leave");
        $('.event_action<%= event.id %>').data("method","put");
        <% spot = event.get_spot %>
        $('.spot<%= event.id %>').html('<%= spot %>');
    <% end %>
    toastr.success('You have joined an event!');
    // $('invitations_count').html('<%= invitations.count %>')
    // $('upcoming_events_count').html('<%= invitations.count %>')
    location.reload();

    // toastr.clear();
  <% else %>

  <% end %>
<% end %>
