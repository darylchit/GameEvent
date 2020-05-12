class PublicGamesController < ApplicationController

  before_action { flash.clear }
  before_action :set_params_for_search
  expose :public_events, :build_public_events
  expose :event, scope: ->{ Event.public_event }
  expose :players, :build_players
  expose :waitlisted, :build_waitlisted
  expose :sorted_games, :build_sorted_games
  expose :sorted_systems, :build_sorted_systems
  expose :countries_list, :build_countries_list
  expose :pending_invitations, :build_pending_invitations
  expose :week_day_query, :build_weekday_query
  expose :no_show, :build_no_show


  respond_to :html, :js

  def index
    if week_day_query.present?
      @q = Event.public_event.future_events.not_cancelled.event_start_order.where(week_day_query.join('or')).search(params[:q])
    else
      @q = Event.public_event.future_events.not_cancelled.event_start_order.search(params[:q])
    end
  end

  private

  def build_public_events
    @q.result.includes(:game_game_system_join, :user).page(params[:page]).per(10)
  end

  def build_players
    event.invites.confirmed.where.not(:user_id => event.user_id).order(:confirmed_at)
  end

  def build_waitlisted
    event.invites.waitlisted.where.not(:user_id => event.user_id).order(:confirmed_at)
  end

  def build_no_show
    event.invites.no_show.where.not(:user_id => event.user_id)
  end

  def build_sorted_games
    Game.active.sort_by &:title
  end

  def build_sorted_systems
    GameSystem.all.sort_by &:title
  end

  def build_countries_list
    { "US"=>"United States", "PR" => 'Puerto Rico' }.merge(ISO3166::Country.translations).invert
  end

  def build_pending_invitations
    event.invites.pending
  end

  def set_params_for_search
    if params[:q].present? && params[:q][:game_type_in].present?
      params[:q][:game_type_in] = params[:q][:game_type_in].split(',')
    end
    if params[:q].present? && params[:q][:play_type_in].present?
      params[:q][:play_type_in] = params[:q][:play_type_in].split(',')
    end
    if params[:q].present? && params[:q][:user_event_percentile_in].present?
      params[:q][:user_event_percentile_in] = (1..params[:q][:user_event_percentile_in].split('-').last.to_i).to_a
    end
    if params[:q].present? && params[:q][:user_psa_rating_in].present?
      params[:q][:user_psa_rating_in] = (1..params[:q][:user_psa_rating_in].split('-').last.to_i).to_a
    end

  end

  def build_weekday_query
    # age limit param setting start
    if params[:age_group].present? && ["13-18","19-26", "27-35", "36-55", "56-99"].include?(params[:age_group])
      if params[:q].present?
        params[:q][:minimum_age_lteq] =  params[:age_group].split('-').last
        params[:q][:maximum_age_gteq] = params[:age_group].split('-').first
      end
    end

    # age limit param setting stop
    day = -1
    week_day_query = []
    if params[:q].present? && params[:q][:start_at_lteq].present?
      if params[:q][:start_at_lteq].to_i == 11
        params[:q][:start_at_gteq] = Time.now
        params[:q][:start_at_lteq] = (Time.now+1.hour)
      elsif params[:q][:start_at_lteq].to_i == 12
        params[:q][:start_at_gteq] = (Time.now+1.hour)
        params[:q][:start_at_lteq] = (Time.now+3.hour)
      elsif params[:q][:start_at_lteq].to_i == 13
        params[:q][:start_at_gteq] = (Time.now+3.hour)
        params[:q][:start_at_lteq] = (Time.now+6.hour)
      elsif params[:q][:start_at_lteq].to_i == 14
        params[:q][:start_at_gteq] = (Time.now+6.hour)
        params[:q][:start_at_lteq] = (Time.now+9.hour)
      elsif params[:q][:start_at_lteq].to_i == 1
        params[:q][:start_at_lteq] = ""
        day = 1
      elsif params[:q][:start_at_lteq].to_i == 2
        params[:q][:start_at_lteq] = ""
        day = 2
      elsif params[:q][:start_at_lteq].to_i == 3
        params[:q][:start_at_lteq] = ""
        day = 3
      elsif params[:q][:start_at_lteq].to_i == 4
        params[:q][:start_at_lteq] = ""
        day = 4
      elsif params[:q][:start_at_lteq].to_i == 5
        params[:q][:start_at_lteq] = ""
        day = 5
      elsif params[:q][:start_at_lteq].to_i == 6
        params[:q][:start_at_lteq] = ""
        day = 6
      elsif params[:q][:start_at_lteq].to_i == 0
        params[:q][:start_at_lteq] = ""
        day = 0
      else
        params[:q][:start_at_lteq] = ""
      end
    end
    if day != -1
      p "find day =========day #{day}=========="
      start_day = Time.now
      until day == (start_day.wday) do
        start_day= start_day+1.day
        p start_day
      end
      p Time.now.wday == day
      p "==================Start day #{start_day}"
      end_day = Event.public_event.future_events.not_cancelled.event_start_order.last.try(:start_at)
      if end_day.present?
        days = []
        until start_day >= end_day do
          days << start_day
          start_day = (start_day + 7.day)
        end
        days.each do |day|
          week_day_query<< "(start_at >= '#{day.beginning_of_day.utc}' and start_at <= '#{day.end_of_day.utc}')"
        end
      end
    end
    week_day_query
  end

end
