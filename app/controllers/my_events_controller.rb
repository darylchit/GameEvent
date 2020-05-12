class MyEventsController < ApplicationController
  before_filter :authenticate_user!
  expose :invitations, :build_invitations
  expose :upcoming_events, :build_upcoming_events
  expose :events, :build_events
  expose :event_sorts, :build_event_sorts
  respond_to :html, :js

  def show
  end

  def my_invitations
  end

  def my_upcoming_events
  end

  def my_all_events
  end

  def my_all_events_more

  end



  private

  def build_invitations
    Event.future_events.joins(:invites).where('invites.user_id' => current_user.id, 'invites.status' => Invite.statuses[:pending]).page(params[:page]).event_start_order.per(4)
  end

  def build_upcoming_events
    Event.upcoming_events.joins(:invites).where('invites.user_id' => current_user.id, 'invites.status' => Invite.statuses[:confirmed]).page(params[:page]).event_start_order.per(4)
  end

  def build_events
    build_all_events.order(start_at: :desc).page(params[:page]).per(10)
  end

  def build_event_sorts
    if params[:sort_by].present? && ['start_at_desc', 'start_at', 'status', 'game', 'hostname'].include?(params[:sort_by])
      if params[:sort_by] == 'start_at'
        build_all_events.order(:start_at).page(params[:page]).per(10)
      elsif params[:sort_by] == 'start_at_desc'
        build_all_events.order(start_at: :desc).page(params[:page]).per(10)
      elsif params[:sort_by] == 'status'
        build_all_events.order(:status).page(params[:page]).per(10)
      elsif params[:sort_by] == 'game'
        build_all_events.order('games.title').page(params[:page]).per(10)
      elsif params[:sort_by] == 'hostname'
        build_all_events.order('users.username').page(params[:page]).per(10)
      else
        build_events
      end
    else
      build_events
    end
  end

  def build_all_events
    Event.joins(:invites, :user, game_game_system_join: :game).where('invites.user_id' => current_user.id, 'invites.status' => Invite.statuses[:confirmed])
  end

end
