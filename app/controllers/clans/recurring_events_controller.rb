class Clans::RecurringEventsController < ApplicationController
  respond_to :html, :js
  before_filter :authenticate_user!

  expose :user_games, :build_games
  expose :recurring_event
  expose :clan do
    Clan.friendly.find(params[:clan_id])
  end

  def new
    respond_to do |format|
      format.js
      format.html {
          redirect_to root_path
      }
    end
  end

  def create
    recurring_event.user_id = current_user.id
    recurring_event.clan_id = clan.id
    recurring_event.save
  end

  def destroy
    if clan.present? && recurring_event.present? && recurring_event.clan_id == clan.id
      recurring_event.destroy
      flash[:notice] = 'Recurring Event Removed'
    end
    redirect_to "#{edit_clan_path(clan)}#clan_recurring_event"
  end

  private

  def recurring_event_params
    permited_params = [:game_game_system_join_id, :pc_type, :game_type, :play_type, :start_time,
                                   :duration, :maximum_size, :title,
                                  :minimum_age, :maximum_age, :frequency, :always_display, :add_founder]
    params.require(:recurring_event).permit( permited_params)
  end

  def build_games
    games = []
    GameGameSystemJoin.active_games.includes(:game, :game_system).order('games.title').each do |gs|
       if gs.game_system.try(:abbreviation) == 'PC'
         games << ["#{gs.game.try(:title)} - Battle.net", gs.id, {class: 'Battletag'}]
         games << ["#{gs.game.try(:title)} - Origin", gs.id, {class: 'Origin'}]
         games << ["#{gs.game.try(:title)} - Steam", gs.id, {class: 'Steam'}]
       else
         games << ["#{gs.game.try(:title)} - #{gs.game_system.try(:abbreviation)}", gs.id, {class: gs.game_system.try(:abbreviation)}]
       end
    end
    games
  end

end
