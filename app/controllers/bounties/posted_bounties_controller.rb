class Bounties::PostedBountiesController < InheritedResources::Base
	before_filter :authenticate_user!
	defaults :resource_class => Bounty
	respond_to :html, :js

	def index
		# NOT USED: see PostedContractsController#index
		
		@grid = initialize_grid(collection,
			order: 'start_date_time',
			order_direction: 'asc',
			per_page: 30,
			name: 'grid',
		)
		super
	end

	def edit
		@games = eligible_games
		super
	end

	def update
		@games = eligible_games
		if resource.status == 'Open'
			update!{edit_posted_bounty_path}
		end

	end

	def new
    @looking_for_players = true
		@games = eligible_games
		super
	end

	def create
		@games = eligible_games
		create!{
			resource.status = "Open"
			resource.save
			events_path
		}
	end

	def destroy
		if resource.cancelable?
			if resource.status == 'Open'
				resource.status = 'Cancelled by Poster'
			else
				resource.status = "Cancelled"
				resource.cancellation_reason = params[:bounty][:cancellation_reason]
				resource.cancellation_note = params[:bounty][:cancellation_note]

				resource.canceler_id = current_user.id
				if resource.cancellation_reason == "Mercenary Quit or Never Showed Up"
					resource.cancellation_assignee = resource.seller
				else
					resource.cancellation_assignee = current_user
				end
				current_user.send_message(resource.seller, "I've cancelled an event that you claimed. [contract id=\"#{resource.id}\"]", "I've cancelled an event that you claimed.", true, nil, Time.now, resource)
			end
			resource.save
      resource.cancellation_assignee.update_cancellation_rate!
		end

			# redirect_to posted_bounties_path, notice: t('.notice_html')
			redirect_to events_path, notice: t('.notice_html')
	end

	def cancel
		@posted_bounty = collection.find(params[:posted_bounty_id])

	end

	def rate
		@posted_bounty = collection.find(params[:posted_bounty_id])

		resource.seller_personality = params[:bounty][:seller_personality]
		resource.seller_skill = params[:bounty][:seller_skill]
		resource.seller_approval = params[:bounty][:seller_approval]
		resource.seller_comment = params[:bounty][:seller_comment]
		resource.seller_feedback_date_time = DateTime.now
		resource.save

		resource.seller.update_rating!

		redirect_to posted_bounty_path(resource), notice: t('.notice_html')
	end

	private
		def permitted_params
      # support posting from the bounty form

      if params['contract']
        params['bounty'] = params['contract']
      end

      params.permit(bounty: [:price_in_dollars, :duration, :details, :level, :player_class, :mission, :start_date_time, :will_play, :play_type, game_game_system_join_ids: []])
		end

    def eligible_games
      current_user.game_game_system_joins.select do |ggs|
        current_user.has_game_system? ggs.game_system
      end
    end


	protected
    def begin_of_association_chain
			current_user
    end

	def self.controller_path
		"bounties/posted_bounties"
	end
end
