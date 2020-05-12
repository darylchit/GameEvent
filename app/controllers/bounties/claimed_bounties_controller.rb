class Bounties::ClaimedBountiesController < InheritedResources::Base
	before_filter :authenticate_user!
	defaults :resource_class => Contract

	def index
		# NOT USED: see PostedContractsController#index

		@grid = initialize_grid(collection.where(seller_id: current_user.id),
			order: 'start_date_time',
			order_direction: 'asc',
			per_page: 30,
			name: 'grid',
		)
		super
	end

	def edit
		edit!{
			redirect_to posted_contracts_path(resource)
		}
	end

	def update
		redirect_to events_path
	end

	def create
		redirect_to events_path
	end

	def destroy
		if resource.cancelable?
			resource.status = "Cancelled"
			resource.cancellation_reason = params[:bounty][:cancellation_reason]
			resource.cancellation_note = params[:bounty][:cancellation_note]

			resource.canceler_id = current_user.id
			if resource.cancellation_reason == "Player Quit or Never Showed Up"
				resource.cancellation_assignee = resource.buyer
			else
				resource.cancellation_assignee = current_user
			end
			current_user.send_message(resource.buyer, "I've cancelled an event that you posted. [contract id=\"#{resource.id}\"]", "I've cancelled an event that you posted.", true, nil, Time.now, resource)
			resource.save
      resource.cancellation_assignee.update_cancellation_rate!
		end
		# redirect_to claimed_bounties_path, notice: t('.notice_html')
		redirect_to claimed_contracts_path, notice: t('.notice_html')
	end

	def cancel
		@claimed_bounty = collection.find(params[:claimed_bounty_id])
	end

	def rate
		@claimed_bounty = collection.find(params[:claimed_bounty_id])

		resource.buyer_personality = params[:bounty][:buyer_personality]
		resource.buyer_skill = params[:bounty][:buyer_skill]
		resource.buyer_approval = params[:bounty][:buyer_approval]
		resource.buyer_comment = params[:bounty][:buyer_comment]
		resource.buyer_feedback_date_time = DateTime.now
		resource.save

		resource.buyer.update_rating!

		redirect_to claimed_bounty_path(resource), notice: t('.notice_html')
	end


	protected
	def begin_of_association_chain
		current_user
	end

	def self.controller_path
		"bounties/claimed_bounties"
	end
end
