attribute :id
node(:image_mobile) do |clan_avatar|
  "#{ENV['domain']}#{image_path clan_avatar.avatar_path}"
end

node(:image) do |clan_avatar|
  "#{ENV['domain']}#{image_path clan_avatar.mobile_jumbo_path}"
end
node(:path) do
  clans_path
end
