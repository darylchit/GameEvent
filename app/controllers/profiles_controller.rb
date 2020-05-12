class ProfilesController < InheritedResources::Base
	defaults :resource_class => User, :collection_name => 'users', :instance_name => 'user'
	expose :is_psn_user_name, :build_psn_user_name
	expose :is_xbox_live_user_name, :build_xbox_live_user_name
	expose :is_nintendo_user_name, :build_nintendo_user_name
	expose :is_battle_user_name, :build_battle_user_name
	expose :is_origins_user_name, :build_origins_user_name
	expose :is_steam_user_name, :build_steam_user_name

	def index
		redirect_to root_path
	end

	def create
		redirect_to root_path
	end

	def edit
		redirect_to root_path
	end
	def update
		redirect_to root_path
	end
	def destroy
		redirect_to root_path
	end

	def show
		@user = User.find_by_username(params[:id])

		if current_user.present? && current_user.is_favoriting_user?(resource)
			@favorite = current_user.favorites.where(:favorited_user_id => resource.id).first
		else
			@favorite = Favorite.new
		end

		if !@user.present?
			redirect_to root_path
		else
			@games = @user.games.uniq
		end

		resource = @user

		@contracts = user_contracts

		@grid = initialize_grid(user_contracts,
			order: 'start_date_time',
			order_direction: 'desc',
			per_page: 30,
			name: 'grid',
		                       )

		if current_user.present?
    	@twitch_stream = TwitchAPI::user_stream(current_user)
    end
		@events = Event.future_events.not_cancelled.public_and_clan_events.joins(:invites).where('invites.user_id' => resource.id, 'invites.status' => Invite.statuses[:confirmed]).event_start_order + Event.past_events.not_cancelled.public_and_clan_events.joins(:invites).where('invites.user_id' => resource.id, 'invites.status' => Invite.statuses[:confirmed]).order('events.start_at desc').limit(10)
		render 'profile/profile/show'
	end

	def feedback
		@user = User.find_by_username(params[:profile_id])
		@rateable_users = User.where('email' => 'jnagybgsu@gmail.com')
		if !@user.present?
			redirect_to root_path
		else
			resource = @user
			@ratings = resource.my_ratings
			render 'profile/profile/feedback'
		end
	end

	def blocks_and_feedback
		@user = current_user
		@rateable_users = current_user.unrated_users.all
		if !@user.present?
			redirect_to root_path
		else
			@blocked = @user.blocks
			resource = @user
			@contracts = Contract.pending_feedback_from_user @user
			render 'profile/profile/blocks_and_feedback'
		end
	end

	def favorites
		@user = User.find_by_username(params[:profile_id])
		if !@user.present?
			redirect_to root_path
		else
			favorites = current_user.favorites.includes(:favorited_user).order('lower(users.username)')

			@grid = initialize_grid(favorites,
				include: :favorited_user,
				order_direction: 'desc',
				per_page: 300,
				name: 'grid',
			)

			render 'profile/profile/favorites'
		end
	end

	#we can refactor this later if we need to, to use jbuilder, etc
	def contracts
		@user = User.find_by_username(params[:profile_id])
		if !@user.present?
			redirect_to root_path
		end

		contracts = []
		if current_admin.present? || (current_user.meets_contract_preferences?(@user) && !@user.is_blocking_user?(current_user))
			(@user.posted_contracts.where(status: "Open") + @user.posted_bounties.where(status: "Open")).each do | c |
				contracts << {
					:id => c.id,
					:start=> c.start_date_time,
					:end=> c.end_date_time,
					:title=> "$#{c.price_in_dollars}",
					:type => c.contract_type
				}
			end
		end
		render :json => contracts
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

	protected
	def user_contracts
		user = User.find_by_username(params[:id])
		if !user.present?
			return Contract.where(:id => nil).where("id IS NOT ?", nil)
		end

		contracts = if current_admin.present? || (current_user.present? && current_user.meets_contract_preferences?(user) && !user.is_blocking_user?(current_user))
			Contract.where('((contract_type = ? AND seller_id = ?) OR (contract_type = ? AND buyer_id = ?) OR (contract_type = ? AND buyer_id = ?)) AND status = ? ', 'Contract', user.id, 'Roster', user.id, 'Bounty', user.id, 'Open')
		else
			Contract.where(:id => nil).where("id IS NOT ?", nil)
		end
		contracts
	end

end
