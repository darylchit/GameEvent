class Api::V1::Bounties::BountiesController < Bounties::BountiesController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Get a list of bounties (rosters). All parameters are optional
  # GET /public-games
  #
  # @param game_ids [Array<Int>] game ids to limit the search to. Will return eligible bounties matching any of these games
  # @param game_system_ids [Array<Int>] game system ids to limit the search to. Will return eligible bounties matching any of these systems
  # @param start_date_time [DateTime] the earliest that a bounty can start. cannot be earlier than now
  # @param end_date_time [DateTime] the latest that a bounty can end. Note that this is not applying itself to the start of the bounty. This is
  #                                 end_date_time <= bounty.start_date_time + bounty.duration
  # @param game_types [Array<String>] what game types player is willing to play. Leave blank to include all types. Note: Using "All Types" is a specific
  #                                   search, not a negation of this filter. {Contract#will_play}
  # @param min_age [Int] the minimum age a user must be. This will exclude anyone without a public age
  # @param max_age [Int] the maximum age a user must be. This will exclude anyone without a public age
  # @param waitlist [Int] 1 to include games that the user will have to waitlist (default), 0 to hide games that are at waitlist
  # @param min_slots_open [Int] The minimum number of slots that must be open
  # @param paid_player [Int] 1 to only include users who have an active subscription on the site
  # @param sort [String] what to sort by. Can be one of `start_date_time`, `duration`, `username`, `psa`, `age`
  # @return [Array<Bounty>] an array of bounties
  def index
    bounties = eligible_bounties
    # wice_grid includes the users portion for the required ratings, so we need to do that manually
    if current_user.personality_rating > 0 || current_user.approval_rating > 0 || current_user.skill_rating > 0 || current_user.cancellation_rate.present? || params[:paid_player] == '1'
      bounties = bounties.joins 'LEFT OUTER JOIN "users" on "users"."id" = "contracts"."buyer_id"'
    end

    # filter by game
    if params[:game_ids].present? && !params[:game_ids].empty?
      bounties = bounties.includes(:game_game_system_joins => :game).where(:games => { :id => params[:game_ids].map{|gid| gid.to_i} })
    end

    # filter by game system
    if params[:game_system_ids].present? && !params[:game_system_ids].empty?
      bounties = bounties.includes(:game_game_system_joins => :game_system).where(:game_systems => { :id => params[:game_system_ids].map{|gsid| gsid.to_i} })
    end

    # start/end date
    if params[:start_date_time].present?
      begin
        start_date_time = ActiveSupport::TimeZone.new(current_user.timezone).local_to_utc(DateTime.parse(params[:start_date_time]))
        bounties = bounties.where 'start_date_time >= ?', start_date_time unless start_date_time < DateTime.now
      rescue => e
        puts e
      end
    end
    if params[:end_date_time].present?
      begin
        end_date_time = ActiveSupport::TimeZone.new(current_user.timezone).local_to_utc(DateTime.parse(params[:end_date_time]))
        bounties = bounties.where 'end_date_time <= ?', end_date_time
      rescue => e
        puts e
      end
    end

    # play type
    if params[:play_types].present? && !params[:play_types].empty?
      bounties = bounties.where :play_type => params[:play_types]
    end

    # age
    if params[:min_age].present?
      bounties = bounties.includes(:buyer).where('users.date_of_birth <= ?', (Time.now - params[:min_age].to_i.years)).where('users.public_age' => true)
    end
    if params[:max_age].present?
      bounties = bounties.includes(:buyer).where('users.date_of_birth >= ?', (Time.now - params[:max_age].to_i.years)).where('users.public_age' => true)
    end

    # waitlist
    if params[:waitlist] == "0"
      # max_roster_size-1 because the owner doesn't have an invite
      bounties = bounties.where('"contracts"."id" NOT IN (SELECT "contracts"."id"
FROM "contracts"
LEFT OUTER JOIN "invites" on "invites"."contract_id" = "contracts"."id"
WHERE "contracts"."contract_type" = \'Roster\'
	AND (("invites"."status" IN (1)))
	AND start_date_time >= NOW()
GROUP BY contracts.id, contract_id
	HAVING count(contract_id) >= (max_roster_size-1))')
    end

    if params[:min_slots_open].present?
      # -1 and +1 are because the owner doesn't have an invite
      bounties = bounties.where('"contracts"."id" NOT IN (SELECT "contracts"."id"
FROM "contracts"
LEFT OUTER JOIN "invites" on "invites"."contract_id" = "contracts"."id"
WHERE "contracts"."contract_type" = \'Roster\'
	AND (("invites"."status" IN (1)))
	AND start_date_time >= NOW()
GROUP BY contracts.id
	HAVING count(contract_id) > (max_roster_size - 1 - ?))', params[:min_slots_open].to_i).where('max_roster_size >= (? + 1)', params[:min_slots_open].to_i)
    end

    # paid players
    if params[:paid_player] == '1'
      bounties = bounties.joins('LEFT OUTER JOIN "subscriptions" on "subscriptions"."user_id" = "contracts"."buyer_id"').where(:subscriptions => { :state => 1 })
    end

    # sorting
    if params[:sort].present? && ['start_date_time', 'duration', 'username', 'psa', 'age'].index(params[:sort]).present?
      bounties = bounties.order :duration if params[:sort] == 'duration'
      bounties = bounties.includes(:buyer).order('users.username') if params[:sort] == 'username'
      bounties = bounties.includes(:buyer).order('users.psa_rating DESC') if params[:sort] == 'psa'
      bounties = bounties.includes(:buyer).order('users.date_of_birth') if params[:sort] == 'age'
    end
    bounties = bounties.limit 50
    bounties = bounties.order :start_date_time # always also order start_date_time

    respond_with bounties, each_serializer: Api::V1::CompactBountySerializer
  end

  # def show
  #   respond_with resource, serializer: Api::V1::ContractSerializer
  # end

  # Claims a contract by the current user
  # POST /contracts/:contract_id/claim
  #
  # @param contract [Contract] required field: `selected_game_game_system_join_id` The selected game_game_system_join_id
  # @return [Contract] `201` the claimed contract if successful
  # @return [Hash] `422` a hash with a message key saying why it couldn't be claimed. Should be shown to the user
  # def claim
	# 	@contract = Contract.find(params[:contract_id])
  #   begin
	#     ggs = GameGameSystemJoin.all.find params[:contract][:selected_game_game_system_join_id]
  #   rescue
  #     render json: { success: false, message: "Game not found" }, status: :unprocessable_entity
  #     return
  #   end
  #
	# 	if !current_user.has_game_system?(ggs.game_system)
	# 		@message = "Sorry, you cannot claim this event as it does not look like you have a compatible game system. You can add a game system by adding and IGN to your Gaming Information for this system.".html_safe
	# 	elsif !@contract.can_be_claimed_by_user?(current_user)
	# 		@message = "Invalid Claim"
	# 	elsif resource.status == "Open"
	# 		if set_claim_parameters
  #       if resource.save
  #         send_claim_message!
  #         respond_with resource, serializer: Api::V1::ContractSerializer
  #       else
  #         logger.warn "****** [%s]" % resource.errors.full_messages
	# 			  @message = "Unable to claim event"
  #       end
	# 		else
	# 			@message = "Please select a game to play."
	# 		end
	# 	else
	# 		@message = "Event Already Claimed"
	# 	end
  #
  #   if @message.present?
  #     render json: { success: false, message: @message }, status: :unprocessable_entity
  #   end
	# end

  protected
  def permitted_params
    params.permit :game_ids
  end
end
