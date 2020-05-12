class Players::PlayersController < InheritedResources::Base
	include SortsAndFilters
	before_action { flash.clear }
	before_filter :set_search_param
	before_filter :authenticate_user!, :except => [:index, :show, :ipn_notification]
	before_filter :get_collection, only: [:index]
	before_filter :filter_params, only: [:index]
	before_filter  :set_search, only: [:index]
	before_filter  :set_order, only: [:index]

	expose :clans, :build_clans

	respond_to :html, :js

	def index
		@games = GameGameSystemJoin.all

		@sorted_games = Game.active.sort_by &:title
		@sorted_systems = GameSystem.all.sort_by &:title

		@players = @resource.page(params[:page]).per(50)
		respond_to do |format|
			format.js
			format.html
		end
	end

	def show
		#temporary, looks like profiles paths are mapped by username?
		redirect_to "/profiles/#{User.find(params[:id]).username}"
	end

	def create
		redirect_to share_path(:id => resource.id)
	end

	def update
		redirect_to contracts_path
	end

	def destroy
		redirect_to contracts_path
	end

	def check_site_password
		# do nothing
	end

	private
	def permitted_params
		params.permit(contract: [:selected_game_game_system_join_id])
  	end

	# def eligible_contracts
	# 	#-------------------------
	# 	# NOTE: Similar logic is in BountiesController and the User model
	# 	#-------------------------

	# 	contracts = Contract.where(status: 'Open').where('start_date_time > ?', Time.now).where(contract_type: 'Contract')

	# 	#blocked
	# 	contract = contracts.where.not(:seller_id => current_user.blocked_by.map{|b| b.user_id}).where.not(:seller_id => current_user.blocks.map{|b| b.blocked_user_id})

	# 	# people who have requirements this player does not meet
	# 	contracts = contracts.where('"users"."required_personality_rating" <= ?', current_user.personality_rating) if current_user.personality_rating > 0
	# 	contracts = contracts.where('"users"."required_approval_rating" <= ?', current_user.approval_rating) if current_user.approval_rating > 0
	# 	contracts = contracts.where('"users"."required_skill_rating" <= ?', current_user.skill_rating) if current_user.skill_rating > 0
	# 	contracts = contracts.where('"users"."required_cancellation_rate" >= ?', current_user.cancellation_rate) if current_user.cancellation_rate.present?

 #    # filter
 #    contracts = contracts.free unless current_user.can_create_paid_contracts?

	# 	contracts
	# end

	def get_collection

		if params.present? && params[:select_filter] &&
				params[:select_filter].is_a?(Hash) &&
				params[:select_filter][:affiliations].present? &&
				params[:select_filter][:affiliations] == "false"

			players = User.where('users.id NOT IN (?)', User.has_clan(Clan.ids).ids.uniq).where(show_on_playerlist: true).includes(:system_avatar, :subscriptions, :active_subscription) #avoid n+1 queries
		else
			players = User.where(show_on_playerlist: true).includes(:system_avatar, :subscriptions, :active_subscription) #avoid n+1 queries
		end



		# if current_user.present?
		# 	#blocked
		# 	players = players.where.not(:id => current_user.blocked_by.map{|b| b.user_id}).where.not(:id => current_user.blocks.map{|b| b.blocked_user_id})
    #
		# 	# people who have requirements this player does not meet
		# 	players = players.where('"users"."required_personality_rating" <= ?', current_user.personality_rating) if current_user.personality_rating > 0
		# 	players = players.where('"users"."required_approval_rating" <= ?', current_user.approval_rating) if current_user.approval_rating > 0
		# 	players = players.where('"users"."required_skill_rating" <= ?', current_user.skill_rating) if current_user.skill_rating > 0
		# 	players = players.where('"users"."required_cancellation_rate" >= ?', current_user.cancellation_rate) if current_user.cancellation_rate.present?
		# end
		#
    # filter
    #contracts = contracts.free unless current_user.can_create_paid_contracts?

    # @last_activity_sort = params[:last_activity_sort]
    # players = players.order(last_sign_in_at: :desc) if  @last_activity_sort
    # #sort premimum users
    # #for some reason this started throwing a pg syntax error..
    # players = players.includes(:active_subscription).order('subscriptions.id ASC')

    @resource = players
	end

	# Using the current `resource`, send a message to the seller from the `current_user` indicating
	# that the event has been claimed
	def send_claim_message!
		subject = "Event Claimed | %s (%s) | %s at %s" % [resource.selected_game_game_system_join.game.title, resource.selected_game_game_system_join.game_system.abbreviation, (resource.start_date_time.strftime "%m/%d"), (resource.start_date_time.strftime "%l:%M%P") ]
		body = "[contract id=\"#{resource.id}\"]"
		current_user.send_message(resource.seller, body, subject, true, nil, Time.now, resource)
		NotificationWorker.perform_async(resource.id, 'Contract', 'Notifications::ContractNotification', 'claimed')
	end

	def build_clans
		Clan.select('id,host_id')
	end

	def set_search_param
		if params.present? && params[:select_filter] &&
				params[:select_filter].is_a?(Hash) &&
				params[:select_filter][:affiliations].present?
			if params[:select_filter][:affiliations] == "true"
				params[:select_filter][:clan]= clans.pluck(:id)
			end
		end
	end

	def set_order
		@resource = if params[:sort_filter].present? &&
									['users.username asc', 'users.username desc',
									 'users.last_sign_in_at desc NULLS LAST',
									 'users.sign_in_count desc',
									].include?(params[:sort_filter])

										@resource.order(params[:sort_filter])
								elsif  params[:sort_filter].present? && params[:sort_filter] == 'psr desc'
									@resource.includes(:user_setting).order('user_settings.psr desc')
								elsif  params[:sort_filter].present? && params[:sort_filter] == 'users.experience'
									@resource.includes(:user_setting).order('user_settings.event_completed desc')

								else

									@resource.order('last_sign_in_at desc NULLS LAST')
								end
	end

end
