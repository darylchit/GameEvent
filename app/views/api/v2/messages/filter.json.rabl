object current_user
attribute :id, :username, :allow_user_messages, :allow_clan_application, :allow_clan_invitations, :allow_site_notices
attribute :allow_private_game_invitations, :allow_public_game_invitations
attribute :allow_event_modified, :allow_event_cancelled, :allow_user_joins_roster, :allow_user_leaves_roster
attribute :event_reminder, :remove_messages, :notif_email
node(:allow_clan_messages) do
  filter_clan_messages
end
node(:allow_clan_game_invitations) do
  filter_clan_game_invitations
end
child(:user_setting) do
  attribute :id, :username, :allow_user_messages, :allow_clan_application, :allow_clan_invitations, :allow_site_notices
  attribute :allow_private_game_invitations, :allow_public_game_invitations
  attribute :allow_event_modified, :allow_event_cancelled, :allow_user_joins_roster, :allow_user_leaves_roster
  attribute :event_reminder
  node(:allow_clan_messages) do
    push_clan_messages
  end
  node(:allow_clan_game_invitations) do
    push_clan_game_invitations
  end
end
