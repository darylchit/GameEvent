class Admin::CancellationsController < ApplicationController
	before_filter :authenticate_admin!

	def index
		unless params[:rosters]
		@grid = initialize_grid(Contract.cancelled.where.not(seller_id: nil),
			order: 'cancelled_at',
			order_direction: 'desc',
			per_page: 30,
			name: 'grid'
			
		)
		else
			@rosters = true
			@grid = initialize_grid(Roster.cancelled.where(seller_id: nil),
			order: 'cancelled_at',
			order_direction: 'desc',
			per_page: 30,
			name: 'grid',
			include: :buyer
		)

		end
	end

  def show
    @resource = resource

		# there's probably a more ruby-ish way to do this
		# collect totals so we can show averages for the users
		@buyer_cancellations = {}
		@seller_cancellations = {}
		Contract.cancellation_reasons.each do |r|
			@buyer_cancellations[r] = 0
			@seller_cancellations[r] = 0
		end

		buyer_total = 0
		resource.buyer.assigned_cancelled_contracts.each do |c|
			@buyer_cancellations[c.cancellation_reason] = 0 unless @buyer_cancellations[c.cancellation_reason].present?
			@buyer_cancellations[c.cancellation_reason] += 1
			buyer_total += 1
		end
		resource.buyer.assigned_cancelled_bounties.each do |c|
			@buyer_cancellations[c.cancellation_reason] = 0 unless @buyer_cancellations[c.cancellation_reason].present?
			@buyer_cancellations[c.cancellation_reason] += 1
			buyer_total += 1
		end
		@buyer_cancellations_total = buyer_total

		seller_total = 0
		resource.seller.assigned_cancelled_contracts.each do |c|
			@seller_cancellations[c.cancellation_reason] = 0 unless @seller_cancellations[c.cancellation_reason].present?
			@seller_cancellations[c.cancellation_reason] += 1
			seller_total += 1
		end
		resource.seller.assigned_cancelled_bounties.each do |c|
			@seller_cancellations[c.cancellation_reason] = 0 unless @seller_cancellations[c.cancellation_reason].present?
			@seller_cancellations[c.cancellation_reason] += 1
			seller_total += 1
		end
		@seller_cancellations_total = seller_total
  end

	def edit

	end

	def update
    unless params[:bounty][:admin_cancellation_note].present?
      flash[:error] = 'Please add a note to the reassignment'
      resource.errors.add(:admin_cancellation_note, 'cannot be empty')
      render 'show'
      return
    end

    resource.cancellation_assignee_id = params[:bounty][:cancellation_assignee_id]
    resource.admin_cancellation_note = params[:bounty][:admin_cancellation_note]
		resource.cancellation_reason = params[:bounty][:cancellation_reason]
    resource.save

    # since we swapped cancellations, update both users involved
    resource.buyer.update_cancellation_rate! 
    resource.seller.update_cancellation_rate! 

    flash[:notice] = 'Cancellation updated'
		redirect_to admin_cancellations_path
	end
	
	def uncancel
		@roster = Roster.find(params[:id])
		@roster.status = "Complete"
    @roster.canceler = nil
    @roster.cancellation_assignee = nil
		if @roster.save 
      @roster.owner.update_cancellation_rate!
			flash[:notice] = "Event #{@roster.id} has been uncancelled"
			redirect_to admin_cancellations_path(:rosters =>true) 
		else
			flash[:notice] = "Something went wrong"
			redirect_to admin_cancellations_path(:rosters =>true)
		end
	end

	protected
	def resource
    return @resource if @resource.present?

		r = Contract.find params[:id]
    @resource = if r.contract_type == 'Contract'
      r
    else
      Bounty.find r.id
    end
	end
end
