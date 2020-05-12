class User::RegistrationsController < Devise::RegistrationsController

	include HomeQuery

	expose :my_clans, :build_my_clans
  expose :active_clans, :build_active_clans
  expose :trending_games, :build_trending_games
  expose :new_games, :build_new_games
  expose :invitations, :build_invitations
  expose :upcoming_events, :build_upcoming_events
  expose :message_count, :build_message_count
  expose :clan_events, :build_clan_events

	skip_before_filter :verify_authenticity_token, :only => :create

	before_filter :configure_sign_up_params, only: [:create]
	before_filter :configure_account_update_params, only: [:update]

	respond_to :html, :js

	# GET /resource/sign_up
	# def new
	#   super
	# end

	# POST /resource
	def create
	  super do |user|
      user.do_country_validation = true
			user.calculate_trial_period params[:promotional_code]
			user.system_avatar_id = rand(1..SystemAvatar.count)
			user.save
		end
	end

	def check_user
	  @user = User.where('LOWER(username) = ?',params[:username].try(:downcase)).first
	end

	def check_email
		@user = User.where('LOWER(email)= ?', params[:email].try(:downcase)).first
	end
	# GET /resource/edit
	# def edit
	#   super
	# end

	# PUT /resource
	# def update
	#   super
	# end

  def profile
    if current_user.update(ign_profile_params)
      flash[:success] = "Profile Complete! Go To The My Account Page To Add Games And Set Presences."
      redirect_to root_path
    else
      if (current_user.errors.messages.keys-User::IGN_USER_NAME_FIELD).empty?
        current_user.reload
				current_user.validate_dublicate_ign = false
        current_user.update(profile_params)
        current_user.assign_attributes(ign_profile_params)
				current_user.validate_dublicate_ign = true
				current_user.valid?
        render :ign_user_profile
      else
        render :user_profile
      end
    end
  end

	# DELETE /resource
	# def destroy
	#   super
	# end

	# GET /resource/cancel
	# Forces the session data which is usually expired after sign
	# in to be expired now. This is useful if the user wants to
	# cancel oauth signing in/up in the middle of the process,
	# removing all OAuth session data.
	# def cancel
	#   super
	# end

	def tosmodal

	end

	protected

	# You can put the params you want to permit in the empty array.
	def configure_sign_up_params
		devise_parameter_sanitizer.for(:sign_up) do |u|
			u.permit( :username, :email, :email_confirmation, :password, :password_confirmation,
				 :age, :source
			)
		end
	end

	# You can put the params you want to permit in the empty array.
	def configure_account_update_params
		devise_parameter_sanitizer.for(:account_update) do |u|
			u.permit(:username, :email, :password, :password_confirmation,
				:first_name, :last_name, :group_name , :address_1, :address_2,
				:city, :state, :zipcode, :country, :avatar, :xbox_live_user_name, :psn_user_name, :nintendo_user_name, :pc_user_name, :language, :timezone,
				:date_of_birth, :public_age, :languages => []
			)
		end
	end

	# The path used after sign up.
	def after_sign_up_path_for(resource)
		thankyou_path
	end

	# The path used after sign up for inactive accounts.
	def after_inactive_sign_up_path_for(resource)
		thankyou_path
  end

  def ign_profile_params
    params.require(:user).permit(:country, :timezone, :language,
																 :newbie_patience_level, :game_style, :will_play,
                                 :most_active_days, :most_active_time, :motto,
                                 :nintendo_user_name, :psn_user_name,
                                 :xbox_live_user_name, :battle_user_name,
																 :notif_email,
                                 :origins_user_name, :steam_user_name, :build_profile, :validate_dublicate_ign)
  end

  def profile_params
    params.require(:user).permit(:country, :timezone, :language,
																 :newbie_patience_level, :game_style, :will_play,
                                 :most_active_days, :most_active_time, :motto, :build_profile,
                                 :nintendo_user_name, :psn_user_name,
                                 :xbox_live_user_name, :battle_user_name,
                                 :origins_user_name, :steam_user_name,
																 :notif_email)
  end

	#stop falsh meassages override from devise

	def is_flashing_format?
		false
	end

end
