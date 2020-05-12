class GameRosters::EventMessagesController < ApplicationController
  before_filter :authenticate_user!

  expose :event, id: :game_roster_id

  respond_to :html, :js

  def index
  	@event_messages = event.event_messages.page(params[:page]).per(10)
  	@page = params[:page]
  end
 
  def create
    @event_message = event.event_messages.new(user: current_user, message: params[:event_message][:message])

    if @event_message.save
      sync_new @event_message
    end
  end

end
