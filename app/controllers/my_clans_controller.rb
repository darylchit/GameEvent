class MyClansController < ApplicationController
  before_filter :authenticate_user!

  def index
  	@events = Event.clan_event.future_events.where(clan_id: current_user.clans.ids).event_start_order
  	@events_count = @events.count
  	@set_offset = 4
  	@my_clans = current_user.clans.order(:name)
  end

  def get_upcoming_events
  	@events = Event.clan_event.future_events.where(clan_id: current_user.clans.ids).event_start_order
  	@offset = params[:offset]
		@offset_add = params[:offset].to_i + 3
		@clan_id = params[:id]
		@total = params[:total_events].to_i
		@show_button = false
		if (@offset_add >= @total)
			@show_button = true
		end
  	respond_to do |format|
  		format.js
  	end
  end
end
