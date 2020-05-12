class Contracts::ClaimedContractsController < InheritedResources::Base
	before_filter :authenticate_user!
	defaults :resource_class => Contract

	def index
		# NOT USED: see PostedContractsController#index

		@grid = initialize_grid(Contract.where('(contract_type = ? and seller_id = ?) OR (contract_type = ? and buyer_id = ?)', 'Bounty', current_user.id, 'Contract', current_user.id),
			order: 'start_date_time',
			order_direction: 'desc',
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
		cancel_contract!
		redirect_to events_path, notice: t('.notice_html')
	end

	def cancel
		@claimed_contract = collection.find(params[:claimed_contract_id])
	end

	def rate
		@claimed_contract = collection.find(params[:claimed_contract_id])

		resource.seller_personality = params[:contract][:seller_personality]
		resource.seller_skill = params[:contract][:seller_skill]
		resource.seller_approval = params[:contract][:seller_approval]
		resource.seller_comment = params[:contract][:seller_comment]
		resource.seller_feedback_date_time = DateTime.now
		resource.save

		resource.seller.update_rating!

		redirect_to claimed_contract_path(resource), notice: t('.notice_html')
	end


	protected
	def begin_of_association_chain
		current_user
	end

	def cancel_contract!
		if resource.cancelable? or resource.completed?
			resource.status = "Cancelled"
			resource.cancellation_reason = params[:contract][:cancellation_reason]
			resource.cancellation_note = params[:contract][:cancellation_note]

			resource.canceler_id = current_user.id
			if resource.cancellation_reason == "Mercenary Quit or Never Showed Up"
				resource.cancellation_assignee = resource.seller
			else
				resource.cancellation_assignee = current_user
			end
      subject = "#{resource.cancellation_assignee.username} Has Cancelled Your Event"
        body = "[contract id=\"#{resource.id}\"]"
      current_user.send_message(resource.seller, body, subject, true, nil, Time.now, resource)
			resource.save
      resource.cancellation_assignee.update_cancellation_rate!
		end
	end

	def self.controller_path
		"contracts/claimed_contracts"
	end
end
