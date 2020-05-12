class PagesController < ApplicationController

	expose :active_faq_headers, :build_active_faq_header

	protect_from_forgery :except => [:default_ipn_notifcation]
	def home
		@games = Game.all
		@users = User.where("confirmed_at IS NOT NULL")
	end
	def about
	end
	def about_new
		if request.format.to_s == '*/*'
			render nothing: true
		else
			render layout: 'about'
		end	  
	end
	def leaderboard
		@top_experience = User.all.order(contracts_completed: :desc).order(psa_rating: :desc)
		@top_personality = User.all.order(personality_rating: :desc).order(contracts_completed: :desc).order(psa_rating: :desc)
		@top_skill = User.all.order(skill_rating: :desc).order(contracts_completed: :desc).order(psa_rating: :desc)
		@top_approval = User.all.order(approval_rating: :desc).order(contracts_completed: :desc).order(psa_rating: :desc)
	end
	def tos
	end

	def zip
		send_file Rails.root.join('Game Roster Images Export.zip'), :type=>"application/zip", :x_sendfile=>true
	end
	def privacy
	end
	def thankyou
		if current_user.present?
			redirect_to root_path
		else
		end
	end
	def faq
	end
	def how_to
	end
	def policies
	end
	def gamestop
	end
	def updates
	end

	def discordapp
		redirect_to 'https://discordapp.com/channels/@me'
	end
	def google_verification
		render :layout => false
	end
	def share
		@event = Contract.where('id' => params[:id]).first
		if @event.roster?
		@event = @event.becomes(Roster)
			if !@event.public?
				redirect_to events_path
			end
		end
	end

	def destiny_landing
		@games = GameGameSystemJoin.where('gameid=9')
		@cover_game = Game.find(9)

		contracts = Contract.where(status: 'Open').where('start_date_time > ?', Time.now).where("contract_type='Contract'").where('game_id=9')

		#blocked
		#contract = contracts.where.not(:seller_id => current_user.blocked_by.map{|b| b.user_id}).where.not(:seller_id => current_user.blocks.map{|b| b.blocked_user_id})

		# people who have requirements this player does not meet
		#contracts = contracts.where('"users"."required_personality_rating" <= ?', current_user.personality_rating) if current_user.personality_rating > 0
		#contracts = contracts.where('"users"."required_approval_rating" <= ?', current_user.approval_rating) if current_user.approval_rating > 0
		#contracts = contracts.where('"users"."required_skill_rating" <= ?', current_user.skill_rating) if current_user.skill_rating > 0
		#contracts = contracts.where('"users"."required_cancellation_rate" >= ?', current_user.cancellation_rate) if current_user.cancellation_rate.present?

		@contracts_grid = initialize_grid(contracts,
			include: [:seller, :game_game_system_joins => [:game_system, :game]],
			order: 'start_date_time',
			order_direction: 'asc',
			per_page: 30,
			name: 'grid',
		)
	end
	#cuz paypal's dumb.
	def default_ipn_notification
		@api = PayPal::SDK::AdaptivePayments::API.new
		if @api.ipn_valid?(request.raw_post)

		end
		#we just need to return a blank 200 so IPN will stop posting back to us
		render :text => ""
	end

	private
	def build_active_faq_header
    FaqHeader.live
  end
end
