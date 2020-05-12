attributes :id, :name
node(:image) do |clan|
  if clan_cover_url(clan).starts_with?('http')
    image_path clan_cover_url(clan)
  else
    "#{ENV['domain']}#{image_path clan_cover_url(clan)}"
  end
end
