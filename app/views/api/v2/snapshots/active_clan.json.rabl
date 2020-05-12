attributes :id, :name
node(:members) do |clan|
  pluralize((clan.clan_members.count), 'Member')
end

node(:events) do |clan|
  pluralize((clan.events.count), 'Event')
end

node(:image) do |clan|
  if clan_mobile_jumbo_url(clan).starts_with?('http')
    image_path clan_mobile_jumbo_url(clan)
  else
    "#{ENV['domain']}#{image_path clan_mobile_jumbo_url(clan)}"
  end
end

node(:image_mobile) do |clan|
  if clan_cover_url(clan).starts_with?('http')
    image_path clan_cover_url(clan)
  else
    "#{ENV['domain']}#{image_path clan_cover_url(clan)}"
  end
end

node(:game) do |clan|
  clan.top_3_games.first.title rescue ""
end
node(:link) do |clan|
  clan_path(clan)
end
