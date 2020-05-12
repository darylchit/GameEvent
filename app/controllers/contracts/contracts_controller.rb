class Contracts::ContractsController < InheritedResources::Base
	include PayPal::Request
	include PayPal::Ipn
	include SortsAndFilters
	before_filter :authenticate_user!, :except =>[:index, :ipn_notification]
	before_filter :get_resource, only: [:index]
	before_filter :filter_params, only: [:index]
	before_filter :set_search, only: [:index]
	respond_to :html, :js
	protect_from_forgery :except => [:close_pay_pal, :ipn_notifcation]

	def index
		@games = GameGameSystemJoin.all

		@sorted_games = Game.all.sort_by &:title
		@sorted_systems = GameSystem.all.sort_by &:title

		 
		@contracts = @resource.page params[:page]
		# filter by the user's preferences for PSA (this is wrong but can be used for filtering the contracts)
		# contracts = contracts.psa_rating_at_or_above(current_user.required_psa_rating) if current_user.required_psa_rating.present?
		# contracts = contracts.personality_rating_at_or_above(current_user.required_personality_rating) if current_user.required_personality_rating.present?
		# contracts = contracts.approval_rating_at_or_above(current_user.required_approval_rating) if current_user.required_approval_rating.present?
		# contracts = contracts.skill_rating_at_or_above(current_user.required_skill_rating) if current_user.required_skill_rating.present?


	    # convert users.date_of_birth "fr" and "to" to dates
	 #    @from_age = params['grid']['f']['users_from_age'].to_i rescue nil
	 #    @to_age = params['grid']['f']['users_to_age'].to_i rescue nil

	 #    if @from_age && @from_age != 0
	 #      from_date = [@from_age,@to_age].max.years.ago
	 #      to_date = [@from_age,@to_age].min.years.ago
	 #      params['grid']['f']['users.date_of_birth']['fr'] = URI.encode(from_date.strftime('%Y/%m/%d'))
	 #      if @to_age != 0
	 #      	params['grid']['f']['users.date_of_birth']['to'] = URI.encode(to_date.strftime('%Y/%m/%d'))
	 #      else
	 #      		params['grid']['f']['users.date_of_birth']['to'] = URI.encode((Time.now + 100.year.to_i).strftime('%Y/%m/%d'))
	 #      end
	 #    end

		# @contracts_grid = initialize_grid(contracts,
		# 	include: [:seller, :game_game_system_joins => [:game_system, :game]],
		# 	order: 'start_date_time',
		# 	order_direction: 'asc',
		# 	per_page: 30,
		# 	name: 'grid',
		# )
		# if params[:grid].present? and params[:grid][:f].present? and params[:grid][:f]["games.id"].present?
		# 	if params[:grid][:f]["games.id"].count == 1
		# 		@cover_game = Game.find(params[:grid][:f]["games.id"][0])
		# 	end
		# 	if params[:grid][:f]["games.id"].count > 1
		# 		@multiple_games = true
		# 	end
		# end
		# super
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

	def claim
		@contract = Contract.find(params[:contract_id])
		ggs = GameGameSystemJoin.all.find params[:contract][:selected_game_game_system_join_id]

		if !current_user.has_game_system?(ggs.game_system)
			@message = "Sorry, you cannot claim this event as it does not look like you have a compatible game system. You can add a game system by <a href=\"#{edit_profile_path}\">adding and IGN</a> to your Gaming Information for this system.".html_safe
			render 'contract_error'
		elsif !@contract.can_be_claimed_by_user?(current_user)
			@message = "Invalid Claim"
			render 'contract_error'
		elsif resource.status == "Open"
			if set_claim_parameters
        if resource.save
          flash[:success] = "Event Claimed"
          send_claim_message!
          render 'contract_claimed'
        else
          logger.warn "****** [%s]" % resource.errors.full_messages
				  render 'contract_error'
        end
			else
				@message = "Please select a title to play."
				render 'contract_error'
			end
		else
			@message = "Contract Already Claimed"
			render 'contract_error'
		end
	end

	def payment_request
		@contract = Contract.find(params[:contract_id])
		@pay_response = build_payment_request(@contract)

		if !@pay_response.success?
			ContractPaypalLog.create(
				contract_id: @contract.id,
				log: @pay_response.error[0].message
			)
			#display error
			flash[:error] = 'There was a problem submitting your payment. Please have the mercenary check their PayPal email address, and try again.'
			redirect_to request.referer
		else
			redirect_to "#{Rails.application.config.adaptive_payments_url}#{@pay_response.payKey}"
		end
	end

	def purchase
		#IPN hasn't come through yet (or is happening right now!), we'll mark it as such for right now
		# This controller handles the return url redirect after the user has
		# completed the payment on pay pal. This redirect is NOT confirmation
		# that the purchase has been completed - it's just for UX purposes while
		# we're waiting for Pay Pal to send the IPN notification, which is the
		# real deal as far as confirming the purchase.  That IPN is handled by
		# the IPN concern.
		resource = Contract.find(params[:contract_id])
		if resource.status == "Invoiced"
			resource.status = "Pending Payment Confirmation from Paypal"
			resource.save
		else
			redirect_to claimed_contracts_path
		end
	end

	def close_pay_pal
		respond_to do |format|
			format.html { render :layout => false }
		end
	end

	def check_site_password
		# do nothing
	end
	private
	def permitted_params
		params.permit(contract: [:selected_game_game_system_join_id])

	end
	
	def get_resource
		#-------------------------
		# NOTE: Similar logic is in BountiesController and the User model
		#-------------------------

		contracts = Contract.where(status: 'Open').where('start_date_time > ?', Time.now).where(contract_type: 'Contract').joins(:seller, :buyer)

		if current_user.present?
			#blocked
			contract = contracts.where.not(:seller_id => current_user.blocked_by.map{|b| b.user_id}).where.not(:seller_id => current_user.blocks.map{|b| b.blocked_user_id})

			# people who have requirements this player does not meet
			contracts = contracts.where('"users"."required_personality_rating" <= ?', current_user.personality_rating) if current_user.personality_rating > 0
			contracts = contracts.where('"users"."required_approval_rating" <= ?', current_user.approval_rating) if current_user.approval_rating > 0
			contracts = contracts.where('"users"."required_skill_rating" <= ?', current_user.skill_rating) if current_user.skill_rating > 0
			contracts = contracts.where('"users"."required_cancellation_rate" >= ?', current_user.cancellation_rate) if current_user.cancellation_rate.present?

    	# filter
    	contracts = contracts.free unless current_user.can_create_paid_contracts?
    end 
    	
		@resource = contracts
	end

	# Using the parameters passed to the controller, sets the parameters for the current user
	# to claim the contract (`resource`).
	#
	# @return [Boolean] `true` if the request is valid to attempt to claim based solely on having
	# 									a game_game_system_join_id, `false` otherwise
	def set_claim_parameters
		if params[:contract].present? and params[:contract][:selected_game_game_system_join_id].present?
			resource.buyer_id = current_user.id
			resource.selected_game_game_system_join_id = params[:contract][:selected_game_game_system_join_id]
			resource.status = "Claimed"
			resource.claimed_at = Time.now
			return true
		end
		false
	end

	# Using the current `resource`, send a message to the seller from the `current_user` indicating
	# that the event has been claimed
	def send_claim_message!
		subject = "Event Claimed | %s (%s) | %s at %s" % [resource.selected_game_game_system_join.game.title, resource.selected_game_game_system_join.game_system.abbreviation, (resource.start_date_time.strftime "%m/%d"), (resource.start_date_time.strftime "%l:%M%P") ]
		body = "[contract id=\"#{resource.id}\"]"
		current_user.send_message(resource.seller, body, subject, true, nil, Time.now, resource)
		NotificationWorker.perform_async(resource.id, 'Contract', 'Notifications::ContractNotification', 'claimed')
	end
end
