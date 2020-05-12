class Api::V1::Contracts::ContractsController < Contracts::ContractsController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Get a list of contracts. All parameters are optional
  #
  # @param game_ids [Array<Int>] game ids to limit the search to. Will return eligible contracts matching any of these games
  # @param game_system_ids [Array<Int>] game system ids to limit the search to. Will return eligible contracts matching any of these systems
  # @param min_price [Int] the minimum suggested donation in cents. For showing only free contracts, set this and `max_price` to 0 (default: 0).
  #                        To exclude free contracts, set to 1
  # @param max_price [Int] the maximum suggested donation. For showing only free contracts, set this and `min_price` to 0. Do not set for no limit
  # @param start_date_time [DateTime] the earliest that a contract can start. cannot be earlier than now
  # @param end_date_time [DateTime] the latest that a contract can end. Note that this is not applying itself to the start of the contract. This is
  #                                 end_date_time <= contract.start_date_time + contract.duration
  # @param durations [Array<Int>] durations in minutes to include in this search
  # @param play_types [Array<String>] the play types to filter by. Leave blank to include all play types.
  # @param game_types [Array<String>] what game types player is willing to play. Leave blank to include all types. Note: Using "All Types" is a specific
  #                                   search, not a negation of this filter. {Contract#will_play}
  # @param min_age [Int] the minimum age a user must be. This will exclude anyone without a public age
  # @param max_age [Int] the maximum age a user must be. This will exclude anyone without a public age
  # @param paid_player [Int] 1 to only include users who have an active subscription on the site
  # @param sort [String] what to sort by. Can be one of `start_date_time`, `duration`, `username`, `psa`, `age`
  # @return [Array<Contract>] an array of contracts
  def index
    contracts = eligible_contracts
    # wice_grid includes the users portion for the required ratings, so we need to do that manually
    if current_user.personality_rating > 0 || current_user.approval_rating > 0 || current_user.skill_rating > 0 || current_user.cancellation_rate.present? || params[:paid_player] == '1'
      contracts = contracts.joins 'LEFT OUTER JOIN "users" on "users"."id" = "contracts"."seller_id"'
    end

    # filter by game
    if params[:game_ids].present? && !params[:game_ids].empty?
      contracts = contracts.includes(:game_game_system_joins => :game).where(:games => { :id => params[:game_ids].map{|gid| gid.to_i} })
    end

    # filter by game system
    if params[:game_system_ids].present? && !params[:game_system_ids].empty?
      contracts = contracts.includes(:game_game_system_joins => :game_system).where(:game_systems => { :id => params[:game_system_ids].map{|gsid| gsid.to_i} })
    end

    # price
    if params[:min_price].present?
      contracts = contracts.where 'price_in_cents >= ?', params[:min_price].to_i
    end
    if params[:max_price].present?
      contracts = contracts.where 'price_in_cents <= ?', params[:max_price].to_i
    end

    # start/end date
    if params[:start_date_time].present?
      begin
        start_date_time = ActiveSupport::TimeZone.new(current_user.timezone).local_to_utc(DateTime.parse(params[:start_date_time]))
        contracts = contracts.where 'start_date_time >= ?', start_date_time unless start_date_time < DateTime.now
      rescue => e
        puts e
      end
    end
    if params[:end_date_time].present?
      begin
        end_date_time = ActiveSupport::TimeZone.new(current_user.timezone).local_to_utc(DateTime.parse(params[:end_date_time]))
        contracts = contracts.where 'end_date_time <= ?', end_date_time
      rescue => e
        puts e
      end
    end

    # duration
    if params[:durations].present? && !params[:durations].empty?
      contracts = contracts.where :duration => params[:durations].map{|d| d.to_i}
    end

    # play type
    if params[:play_types].present? && !params[:play_types].empty?
      contracts = contracts.where :play_type => params[:play_types]
    end

    # age
    if params[:min_age].present?
      contracts = contracts.includes(:seller).where('users.date_of_birth <= ?', (Time.now - params[:min_age].to_i.years)).where('users.public_age' => true)
    end
    if params[:max_age].present?
      contracts = contracts.includes(:seller).where('users.date_of_birth >= ?', (Time.now - params[:max_age].to_i.years)).where('users.public_age' => true)
    end

    # paid players
    if params[:paid_player] == '1'
      contracts = contracts.joins('LEFT OUTER JOIN "subscriptions" on "subscriptions"."user_id" = "contracts"."seller_id"').where(:subscriptions => { :state => 1 })
    end

    # will play
    if params[:game_types].present? && !params[:game_types].empty?
      contracts = contracts.where :will_play => params[:game_types]
    end

    # sorting
    if params[:sort].present? && ['start_date_time', 'duration', 'username', 'psa', 'age'].index(params[:sort]).present?
      contracts = contracts.order :duration if params[:sort] == 'duration'
      contracts = contracts.includes(:seller).order('users.username') if params[:sort] == 'username'
      contracts = contracts.includes(:seller).order('users.psa_rating DESC') if params[:sort] == 'psa'
      contracts = contracts.includes(:seller).order('users.date_of_birth') if params[:sort] == 'age'
    end

    contracts = contracts.limit 50
    contracts = contracts.order :start_date_time # always also order start_date_time

    respond_with contracts, each_serializer: Api::V1::CompactContractSerializer
  end

  def show
    if resource.contract?
      respond_with resource, serializer: Api::V1::ContractSerializer
    else
      render json: { success: false, message: "Contract not found" }, status: :not_found
    end
  end

  # Claims a contract by the current user
  # POST /contracts/:contract_id/claim
  #
  # @param contract [Contract] required field: `selected_game_game_system_join_id` The selected game_game_system_join_id
  # @return [Contract] `201` the claimed contract if successful
  # @return [Hash] `422` a hash with a message key saying why it couldn't be claimed. Should be shown to the user
  def claim
		@contract = Contract.find(params[:contract_id])
    begin
	    ggs = GameGameSystemJoin.all.find params[:contract][:selected_game_game_system_join_id]
    rescue
      render json: { success: false, message: "Title not found" }, status: :unprocessable_entity
      return
    end

		if !current_user.has_game_system?(ggs.game_system)
			@message = "Sorry, you cannot claim this event as it does not look like you have a compatible game system. You can add a game system by adding and IGN to your Gaming Information for this system.".html_safe
		elsif !@contract.can_be_claimed_by_user?(current_user)
			@message = "Invalid Claim"
		elsif resource.status == "Open"
			if set_claim_parameters
        if resource.save
          send_claim_message!
          respond_with resource, serializer: Api::V1::ContractSerializer
        else
          logger.warn "****** [%s]" % resource.errors.full_messages
				  @message = "Unable to claim event"
        end
			else
				@message = "Please select a title to play."
			end
		else
			@message = "Event Already Claimed"
		end

    if @message.present?
      render json: { success: false, message: @message }, status: :unprocessable_entity
    end
	end

  protected
  def permitted_params
    params.permit :game_ids
  end
end
