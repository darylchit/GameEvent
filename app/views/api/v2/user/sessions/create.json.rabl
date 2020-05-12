if @user_setting == true
  object current_user
  attribute :id, :username, :age, :authentication_token
  node(:url_parameter) do |user|
    token = user.web_token
    "?u=#{token[16...20]}&x=#{user.username}&a=#{token[8...12]}&e=#{token[0...4]}&i=#{token[12...16]}&o=#{token[4...8]}"
  end
else
  node(:error) do
    'Token and Type Not valid'
  end
end
