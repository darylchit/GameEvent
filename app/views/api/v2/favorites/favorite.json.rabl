attributes :id, :username
node(:image) do |user|
 if user.avatar_url_with_domain.starts_with?('http')
   image_path user.avatar_url_with_domain
 else
   "#{ENV['domain']}#{image_path user.avatar_url_with_domain}"
 end
end
