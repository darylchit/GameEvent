class Api::V2::SnapshotsController < ApplicationController
  include MessageQuery

  respond_to :json

  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User

  expose :invitations, :build_invitations
  expose :upcoming_events, :build_upcoming_events
  expose :clan_events, :build_clan_events
  expose :messages_count, :build_messages_count

  expose :my_clans, :build_my_clans
  expose :active_clans, :build_active_clans
  expose :trending_games, :build_trending_games
  expose :new_games, :build_new_games
  expose :random_data, :build_random_data


  def index

  end

  private

  def build_random_data
    {
      clan_avatars: ClanAvatar.limit(5),
      games: Game.active.limit(5)
    }
  end

  def build_invitations
    Event.future_events.joins(:invites)
        .where('invites.user_id' => current_user.id, 'invites.status' => Invite.statuses[:pending])
  end
  def build_upcoming_events
    Event.upcoming_events.joins(:invites).
        where('invites.user_id' => current_user.id, 'invites.status' => Invite.statuses[:confirmed])
  end

  def build_clan_events
    Event.clan_event.future_events.where(clan_id: current_user.clans.ids)
  end

  def build_messages_count
    build_messages.unread.count + build_clan_messages.unread.count + build_event_notices.unread.count
  end

  def build_my_clans
    if current_user
    current_user.clans
        .joins('LEFT JOIN events ON clans.id = events.clan_id')
        .group(:id)
        .order('COUNT(events.id) DESC')
        .limit(5)
    else
      Clan.where(id: nil)
    end
  end

  def build_active_clans
    Clan
        .order('activity_score DESC NULLS LAST')
        .limit(5)
  end

  def build_trending_games
    Game.active.joins('LEFT JOIN game_game_system_joins ON games.id = game_game_system_joins.game_id
                LEFT JOIN events ON game_game_system_joins.id = events.game_game_system_join_id')
        .where('events.created_at > ?', Time.now-1.month)
        .where('release_date < ? or release_date is NULL', Time.now)
        .group(:id)
        .order('count(events.id) DESC')
        .limit(5)
  end

  def build_new_games
    Game.active.new_releases
        .limit(5)
        .order(:release_date)
  end

end
