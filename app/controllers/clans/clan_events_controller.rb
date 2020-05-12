class Clans::ClanEventsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  expose :event, scope: ->{ Event.clan_event }
  expose :pending_invitations, :build_pending_invitations
  expose :players, :build_players
  expose :waitlisted, :build_waitlisted
  expose :no_show, :build_no_show
  respond_to :html, :js

	def index
		@clan = Clan.find(params[:clan_id])
    @clan_donation = @clan.clan_donations.new
		#@events = @clan.get_contracts.where('start_date_time > now()').order("start_date_time ASC").page(params[:page]).per(params[:per_page])
    @events = Contract.all.where('date(start_date_time) > now()').order("start_date_time ASC").page(params[:page])
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
	end


  private

  def build_pending_invitations
    event.invites.pending
  end

  def build_players
    event.invites.where(:status => 1).where.not(:user_id => event.user_id).order(:confirmed_at).limit(event.maximum_size - 1)
  end

  def build_waitlisted
    event.invites.where(:status => 1).where.not(:user_id => event.user_id).order(:confirmed_at).offset(event.maximum_size - 1)
  end

  def build_no_show
    event.invites.where(status: 4).where.not(:user_id => event.user_id)
  end
end
