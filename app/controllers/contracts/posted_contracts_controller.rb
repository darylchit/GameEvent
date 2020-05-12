class Contracts::PostedContractsController < InheritedResources::Base
	before_filter :authenticate_user!
	defaults :resource_class => Contract

	def new

		@games = eligible_games
		super
	end

	def edit
		@games = eligible_games
		super
	end

	def update
		@games = eligible_games
		if resource.status == 'Open'
			update!{edit_posted_contract_path}
		end
	end

	def create
		@games = eligible_games
		@contract = build_resource
		if params[:start_date_times_durations].present?
			ActiveRecord::Base.transaction do
				begin
					params[:start_date_times_durations].each_with_index do | sdtd |
						resource = Contract.new(permitted_params[:contract])
						resource.seller = current_user
						resource.start_date_time = sdtd[1][:start_date_time]
						resource.duration = sdtd[1][:duration].to_i
						resource.status = "Open"
						resource.save!
					end
				rescue ActiveRecord::RecordInvalid => exception
					resource.errors.add(:base, exception.message)

					render 'new'
					return
				end
			end
			redirect_to events_path, notice: t('.notice_html')
		else
			create!{
				resource.status = "Open"
				resource.save
				share_path(:id => resource.id)
			}
		end
	end

	def destroy
		cancel_contract!
		redirect_to events_path, notice: t('.notice_html')
	end

	def cancel
		@posted_contract = collection.find(params[:posted_contract_id])

	end

	def rate
		@posted_contract = collection.find(params[:posted_contract_id])

		resource.buyer_personality = params[:contract][:buyer_personality]
		resource.buyer_skill = params[:contract][:buyer_skill]
		resource.buyer_approval = params[:contract][:buyer_approval]
		resource.buyer_comment = params[:contract][:buyer_comment]
		resource.buyer_feedback_date_time = DateTime.now
		resource.save

		resource.buyer.update_rating!

		redirect_to posted_contract_path(resource), notice: t('.notice_html')
	end

	def multiple_times_new

	end

	def multiple_times_create
		#invert keys, will make the next step easier
		meeting_times = []
		params[:multiple_times][:day_of_week].each_with_index do | value, key |
			meeting_times[key] = {}
			meeting_times[key][:day_of_week] = params[:multiple_times][:day_of_week][key]
			meeting_times[key][:starts_at] = params[:multiple_times][:starts_at][key]
			meeting_times[key][:duration] = params[:multiple_times][:duration][key]
		end


		start_date = params[:start_date]
		end_date = params[:end_date]

		@errors = []

		begin
			if(Date.parse(start_date) > Date.parse(end_date))
				@errors << {:selector => '.start-end-dates',  :message => 'Start Date must be on or before End Date'}
			end
		rescue
			@errors << {:selector => '.start-end-dates',  :message => 'Invalid Start Date or End Date'}
			return
		end

		schedules = []
		meeting_times.each_with_index do | meeting_time, key |

			start_time = Time.parse(start_date + ' ' +  meeting_time[:starts_at])
			# Ice_cube can be very confusing.  The end time is not the end of the recurrence,
			# It's the end of the event itself.  So the endtime uses the start date,
			# not the end date.  The end date is used in the "until" function call below.
			end_time = start_time.advance(:minutes => meeting_time[:duration].to_i)

			schedule = IceCube::Schedule.new(start_time, :end_time => end_time)
			day_of_week = meeting_time[:day_of_week].parameterize.underscore.to_sym
			schedule.add_recurrence_rule IceCube::Rule.weekly().day(day_of_week).until(end_date)
			schedule.each_occurrence { | mt |
				if(mt.start_time > Time.now) and (mt.start_time < Time.now.advance(:months => 3))
					schedules << [mt.start_time, meeting_time[:duration].to_i]
				end
			}
		end
		@schedules = schedules

	end

	private
    def permitted_params
      # support posting from the bounty form

      if params['bounty']
        params['contract'] = params['bounty']
      end

      params.permit(contract: [:start_date_time, :duration, :price_in_dollars,:details, :will_play, :play_type, game_game_system_join_ids: []])
    end

	protected
    def begin_of_association_chain
		current_user
    end

		def eligible_games
			current_user.game_game_system_joins.select do |ggs|
				current_user.has_game_system? ggs.game_system
			end
		end

		def cancel_contract!
			if resource.cancelable? or resource.completed?
				if resource.status == 'Open'
					resource.status = 'Cancelled by Poster'
				else
					resource.status = "Cancelled"
					resource.cancellation_reason = params[:contract][:cancellation_reason]
					resource.cancellation_note = params[:contract][:cancellation_note]

					resource.canceler = current_user
					if resource.cancellation_reason == "Player Quit or Never Showed Up"
						resource.cancellation_assignee = resource.buyer
					else
						resource.cancellation_assignee = current_user
					end
          subject = "#{resource.cancellation_assignee.username} Has Cancelled an Event You Claimed"
          body = "[contract id=\"#{resource.id}\"]"
          current_user.send_message(resource.buyer, body, subject, true, nil, Time.now, resource)
				end
				resource.save
	      resource.cancellation_assignee.update_cancellation_rate! if resource.cancellation_assignee.present?
			end
		end

		def self.controller_path
			"contracts/posted_contracts"
		end
end
