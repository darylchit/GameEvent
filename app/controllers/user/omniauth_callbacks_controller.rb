class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def discord
    @is_login = !current_user.present?

    auth = request.env['omniauth.auth']
    unless @auth = Authorization.find_from_hash(auth, params[:guild_id], current_user)
      # Create a new user or add an auth to existing user, depending on
      # whether there is already a user signed in.
      if current_user.present?
        @auth = Authorization.create_from_hash(auth, params[:guild_id], current_user)
      end

    end

    if @auth.present? && @is_login == true
      sign_in(:user, @auth.user)
    end

    respond_to do|format|
      format.html {  }
      format.js
    end


    # bot = Discordrb::Bot.new token: "MzQxNjMxMjQ3NjA2NjExOTY4.DGJZXQ.bCmOiiVStbcjQskpmsMeqmjpVhI", client_id: 341631247606611968
    #
    # bot.run :asynk
    #
    # bot.gateway
    # p @auth
    # p bot
    # discord_server = nil
    # bot.servers.values.each do |s|
    #   p s
    #   p s.owner
    #  if s.owner.id ==  @auth.uid.to_i
    #    discord_server = s
    #    break
    #   end
    # end
    # p discord_server
    # p discord_server.channels
    # if discord_server.present? && discord_server.is_a?(Discordrb::Server)
    #   discord_server.channels.each do|channel|
    #     channel.send_message(Time.now.to_s) rescue nil
    #   end
    # end
    # exit


  end
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when omniauth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
