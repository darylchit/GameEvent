class Profile::ProfileController < InheritedResources::Base
	defaults :resource_class => User
	include UserPreferences
	before_filter :authenticate_user!
	before_filter :update_preferences_params, only: [:update]
	respond_to :html
	expose :is_psn_user_name, :build_psn_user_name
	expose :is_xbox_live_user_name, :build_xbox_live_user_name
	expose :is_nintendo_user_name, :build_nintendo_user_name
	expose :is_battle_user_name, :build_battle_user_name
	expose :is_origins_user_name, :build_origins_user_name
	expose :is_steam_user_name, :build_steam_user_name
	expose :my_clans, :build_my_clans

	def show
		@game_systems_size = GameSystem.count
		@grid = initialize_grid(user_contracts,
			order: 'start_date_time',
			order_direction: 'desc',
			per_page: 30,
			name: 'grid',
		)
		@games = resource.games.uniq
		#@twitch_stream = TwitchAPI::user_stream(current_user)
	end

	def edit
		@dup_user = resource.dup
		@dup_user.paypal_email = @dup_user.paypal_email || @dup_user.email
		@game_systems = GameSystem.preload(:game_game_system_joins => [:game]).order('display_rank')
		@site_averages = site_averages
		@favorites = current_user.favorites.includes(:favorited_user)#.order('lower(users.username)')
		@blocked_users = current_user.blocks.includes(:blocked_user)
		super
	end

	def update
		@dup_user = resource.dup
		@dup_user.paypal_email = @dup_user.paypal_email || @dup_user.email
		if params[:user][:avatar].present?
			resource.update(:custom_avatar => true)
		end
		resource.build_profile = true
		resource.validate_game = true
		@game_systems = GameSystem.preload(:game_game_system_joins => [:game]).order('display_rank')
		@site_averages = site_averages
		step = params[:step]
		newEmail = params[:user][:email]

		if resource.is_pro_or_elite? && params[:user].present? && params[:user][:system_avatar_id].present? && !params[:user][:avatar].present?

			p '============='
			p  system_avatar = SystemAvatar.find(params[:user][:system_avatar_id])
			p image_path = "app/assets/images/avatars/#{system_avatar.name}"
			if system_avatar.present? && resource.system_avatar_id != system_avatar.id
				p '============================'
				if File.exist?(image_path)
					p image_file = File.open(image_path)
					p   resource.avatar.store!(image_file)
				end
			end
			p '============'
		end



=begin
		if resource.is_pro_or_elite? && params[:user].present? && params[:user][:system_avatar_id].present? && !params[:user][:avatar].present?
      system_avatar = SystemAvatar.find(params[:user][:system_avatar_id])
      if system_avatar.present? && resource.system_avatar_id != system_avatar.id

			# image_path = "app/assets/images/avatars/#{system_avatar.name}"

      p 'test'
			# p image_path


      # if File.exits?(image_path)
      # avatar = resource.avatar
      # image_file = File.open(image_path)
      # avatar.store! image_file
      # end

		end
=end
		# update!{edit_profile_path(step: step)}
		update! do |success, failure|
			success.html do
				sign_in(resource, :bypass => true) # prevent from sign out while change the password
				if (resource.unconfirmed_email.present? && newEmail.present? && newEmail != resource.email && step.to_i == 3 )
					redirect_to edit_profile_path(step: step, changed_email: true)
				else
				 redirect_to edit_profile_path(step: step)
				end
			end
		end
	end

	def create
		redirect_to edit_profile_path
	end

	def destroy
		redirect_to edit_profile_path
	end

	def remove_profile
		respond_to do |format|
			format.js
			format.html { redirect_to edit_profile_path}
		end
	end

	def delete_profile
		@deleted = false
		if params['confirmation'].present? && params[:confirmation] == 'DELETE'
			@deleted = true
			current_user.user_setting.update_attributes(bete_deleted: Time.now) rescue nil
		end
	end

	def ign
		if params[:save].present?
			current_user.update(new_ign_params)
		elsif params[:remove_pc_user_name].present?
			current_user.pc_user_name = nil
			current_user.save
		end
		redirect_to root_path
	end

	private
	def permitted_params
		permitted_attributes = [:bio, :avatar, :custom_avatar, :timezone,
														:language, :allow_clan_application, :notif_email, :remove_messages,
														:allow_user_messages, :allow_clan_invitations, :allow_private_game_invitations,
														:allow_public_game_invitations, :allow_site_notices, :event_reminder,
														:allow_event_modified, :allow_event_cancelled, :allow_user_joins_roster, :allow_user_leaves_roster,
														:psn_user_name, :xbox_live_user_name, :nintendo_user_name,
														:battle_user_name, :origins_user_name, :steam_user_name,
														:will_play, :newbie_patience_level, :motto,
														:country, :most_active_days, :most_active_time, :public_age, :show_on_playerlist,
														:game_style, :playing_for_charity,
														:charity, :charity_id, :required_personality_rating,
														:required_approval_rating, :required_skill_rating,
														:required_cancellation_rate, :age, :system_avatar_id,
														:youtube, :twitch, :facebook, :google_plus, :twitter, :instagram, :battlelog, :patreon, :destiny, :guardian_gg, :steam, :league_of_legends, :overwatch, :world_of_warcraft,
														:scuf, :mixer_url,
														video_urls_attributes: [:id, :name, :url, :_destroy],
														game_game_system_join_ids: [],
														allow_clan_messages: [],
														allow_clan_game_invitations: []

		]
		if params[:user] and ( params[:user][:password].present? or params[:user][:password_confirmation].present?)
			permitted_attributes << :password
			permitted_attributes << :password_confirmation
		end

		if params[:user] and ( params[:user][:email].present? or params[:user][:email_confirmation].present?)
			permitted_attributes << :email
			permitted_attributes << :email_confirmation
		end

		if params[:user] and ( params[:user][:paypal_email].present? or params[:user][:paypal_email_confirmation].present?)
			permitted_attributes << :paypal_email
			permitted_attributes << :paypal_email_confirmation
		end
		params.permit(user: permitted_attributes)
	end

	protected
    def resource
      current_user
    end
	def site_averages
		{
			personality_rating: User.average(:personality_rating).floor,
			approval_rating: User.average(:approval_rating).floor,
			skill_rating: User.average(:skill_rating).floor,
			cancellation_rate: ((Contract.cancelled.count.to_f / [Contract.closed.count.to_i, 1].max) * 100).round
		}
	end
	def user_contracts
		user = current_user
		Contract.where('((contract_type = ? AND seller_id = ?) OR (contract_type = ? AND buyer_id = ?)) AND status = ? ', 'Contract', user.id, 'Roster', user.id, 'Open')
	end

	def new_ign_params
		params.require(:user).permit(:battle_user_name, :origins_user_name, :steam_user_name)
	end

	def build_my_clans
		current_user.clans.order(:name)
	end

	def build_psn_user_name
		if current_user.psn_user_name?
			User.where("lower(psn_user_name) =? AND id != ? ", current_user.psn_user_name.downcase, current_user).present?
		else
			false
		end
	end

	def build_xbox_live_user_name
		if current_user.xbox_live_user_name?
			User.where("lower(xbox_live_user_name) =? AND id != ? ", current_user.xbox_live_user_name.downcase, current_user).present?
		else
			false
		end
	end

	def build_nintendo_user_name
		if current_user.nintendo_user_name?
			User.where("lower(nintendo_user_name) =? AND id != ? ", current_user.nintendo_user_name.downcase, current_user).present?
		else
			false
		end
	end

	def build_battle_user_name
		if current_user.battle_user_name?
			User.where("lower(battle_user_name) =? AND id != ? ", current_user.battle_user_name.downcase, current_user).present?
		else
			false
		end
	end

	def build_origins_user_name
		if current_user.origins_user_name?
			User.where("lower(origins_user_name) =? AND id != ? ", current_user.origins_user_name.downcase, current_user).present?
		else
			false
		end
	end

	def build_steam_user_name
		if current_user.steam_user_name?
			User.where("lower(steam_user_name) =? AND id != ? ", current_user.steam_user_name.downcase, current_user).present?
		else
			false
		end
	end

end
