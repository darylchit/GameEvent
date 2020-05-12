class GameRostersController < ApplicationController

  include DiscordBot

  before_filter :authenticate_user!, except: [:show, :share, :discord_post]
  before_action { flash.clear }
  expose :event
  expose :users, :build_users
  expose :user_clans, :build_user_clans
  expose :user_games, :build_games
  expose :players, :build_players
  expose :waitlisted, :build_waitlisted
  expose :pending_invitations, :build_pending_invitations
  expose :no_show, :build_no_show

  # for discord Form
  expose :clan, :build_clan
  expose :pending_clan_application do
    if clan.present? && current_user.present?
     current_user.clan_applications.find_by_clan_id(clan.id)
    end
  end
  expose :rejected_clan_application do
    if clan.present? && current_user.present?
      current_user.clan_applications.deleted.find_by_clan_id_and_status(clan.id, false)
    end
  end
  # discord form END

  respond_to :html, :js

  def new
    respond_to do |format|
      format.js
      format.html {
          redirect_to root_path
      }
    end
  end

  def discord_post
    render :new
  end

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

  def update
    maximum_size =  event.maximum_size
    event_dup = event.dup
   if event.update(event_params)
     event.invite_private_event_payers
     unless current_user.game_game_system_joins.find_by_id(event.game_game_system_join_id)
       current_user.game_game_system_joins << event.game_game_system_join
     end
     current_user.update(ign_params)
     event.set_status_and_shift_players_to_and_from_waitlist_to_player_list! unless maximum_size == event.maximum_size
     if (event_dup.start_at != event.start_at) || (event_dup.title != event.title) || (event_dup.game_game_system_join_id != event.game_game_system_join_id)
       event.send_notification_for_event_updates
     end
   end

  end

  def cancel
    event.make_cancel!
  end

  def cancelled_event
  end

  def discord_channels
    @event = Event.find(params[:id])
    @channels = get_channels(current_user)
  end

  def discord
    if params[:channels]
     send_event_message(current_user, params[:url], params[:channels])
    end
  end

  def share
    respond_to do |format|
      format.js
      format.html { redirect_to global_show_event_path(event)}
    end
  end

  private

  def event_params
    permited_params = [:game_game_system_join_id, :pc_type, :game_type, :play_type, :start_at,
                                   :duration, :allow_waitlist, :maximum_size, :title, :details,
                                  :minimum_age, :maximum_age, :private_invite_ids => []]
    permited_params << [:event_type,  :clan_id]   if action_name == "create"
    params.require(:event).permit( permited_params)
  end

  def ign_params
    params.require(:event).permit([:psn_user_name, :xbox_live_user_name, :nintendo_user_name, :battle_user_name, :origins_user_name, :steam_user_name])
  end

  def build_players
    if event.recurring_event?
      event.invites.where(:status => 1)
    else
      event.invites.where(:status => 1).where.not(:user_id => event.user_id)
    end
  end

  def build_waitlisted
    if event.recurring_event?
      event.invites.where(:status => 3)
    else
      event.invites.where(:status => 3).where.not(:user_id => event.user_id)
    end
  end

  def build_user_clans
    if current_user
      current_user.clans.select('clans.id,clans.name')
    else
      Clan.where(id: 0)
    end
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
    # map{|gs|["#{gs.game.try(:title)}- #{gs.game_system.try(:abbreviation)}", gs.id, {class: gs.game_system.try(:abbreviation)}]}
  end

  def invite_params
    params.require(:invite).permit(:contract_id, :status, :position)
    Invite(id: integer, contract_id: integer, user_id: integer, status: integer,
    created_at: datetime, updated_at: datetime, position: integer, event_id: integer)
  end

  def build_users
    if current_user
      current_user.favorites
    else
      Favorite.where(id: 0)
    end
  end

  def build_pending_invitations
    if event.recurring_event?
      event.invites.where(status: 0)
    else
      event.invites.where(status: 0).where.not(:user_id => event.user_id)
    end
  end

  def build_no_show
    if event.recurring_event?
      event.invites.where(status: 4)
    else
      event.invites.where(status: 4).where.not(:user_id => event.user_id)
    end
  end

  def build_clan
    Clan.find_by_slug(params[:clan_id])
  end

end
