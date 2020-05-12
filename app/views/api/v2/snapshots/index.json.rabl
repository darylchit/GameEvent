
node(:messages) do
  messages_count
end

node(:clan_events) do
  clan_events.count
end

node(:invitations) do
  invitations.count
end

node(:upcoming_events) do
  upcoming_events.count
end

child trending_games => :trending_games do
  extends "api/v2/snapshots/game"
end


child new_games => :comming_soons do
  extends "api/v2/snapshots/game"
end

child active_clans => :active_clans do
  extends "api/v2/snapshots/active_clan"
end

child my_clans => :my_clans do
  extends "api/v2/snapshots/my_clan"
end

child random_data[:clan_avatars] => :avatars do
  extends "api/v2/snapshots/clan_avatar"
end

child random_data[:games] => :random_games do
  extends "api/v2/snapshots/random_game"
end
