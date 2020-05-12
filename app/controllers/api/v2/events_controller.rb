class Api::V2::EventsController < Api::V2::BaseController

  #new event data
  expose :event_types, :build_event_types
  expose :user_clans, :build_user_clans
  expose :subscription_plan, :plan_name
  expose :user_games, :build_user_games
  expose :users, :build_users

  #create event
  expose :event

  def create
    event.user_id = current_user.id
    if event.save
      event.invite_private_event_payers
      unless current_user.game_game_system_joins.find_by_id(event.game_game_system_join_id)
        current_user.game_game_system_joins << event.game_game_system_join
      end
      current_user.update(ign_params)
    end
  end

  private

  def event_params
    params[:event][:private_invite_ids] = params[:event][:private_invite_ids].values if params[:event][:private_invite_ids].present? && params[:event][:private_invite_ids].is_a?(Hash)

    permited_params = [:game_game_system_join_id, :game_type, :play_type, :start_at,
                                   :duration, :allow_waitlist, :maximum_size, :title, :details,
                                  :minimum_age, :maximum_age, :private_invite_ids => []]
    permited_params << [:event_type,  :clan_id]   if action_name == "create"
    params.require(:event).permit( permited_params)
  end

  def ign_params
    params.require(:event).permit([:psn_user_name, :xbox_live_user_name, :nintendo_user_name, :battle_user_name, :origins_user_name, :steam_user_name])
  end

  def build_event_types
    Event.event_types.map{|k,v| [k.titleize,k] }
  end

  def build_user_clans
    current_user.clans.select('clans.id,clans.name').map{|c|[c.name, c.id]}
  end

  def plan_name
     current_user.active_subscription.try(:subscription_plan).try(:name)
  end

  def build_user_games
    games = []
    GameGameSystemJoin.includes(:game, :game_system).where('games.active = ?', true).order('games.title').each do |gs|
       if gs.game_system.try(:abbreviation) == 'PC'
         games << ["#{gs.game.try(:title)}- Battletag", gs.id, 'Battletag']
         games << ["#{gs.game.try(:title)}- Origin", gs.id, 'Origin']
         games << ["#{gs.game.try(:title)}- Steam", gs.id, 'Steam']
       else
         games << ["#{gs.game.try(:title)}- #{gs.game_system.try(:abbreviation)}", gs.id, gs.game_system.try(:abbreviation)]
       end
    end
    games
  end

  def build_users
    current_user.favorites.collect{|u| [u.favorited_user.username, u.favorited_user.id]}
  end

end
