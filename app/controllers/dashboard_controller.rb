class DashboardController < ApplicationController

  include HomeQuery

  expose :my_clans, :build_my_clans
  expose :active_clans, :build_active_clans
  expose :trending_games, :build_trending_games
  expose :new_games, :build_new_games
  expose :invitations, :build_invitations
  expose :upcoming_events, :build_upcoming_events
  expose :message_count, :build_message_count
  expose :clan_events, :build_clan_events

  before_action :authenticate_user!
  respond_to :html, :js

  def index

=begin
    @user = current_user


    @games_path = 'dashboard/partials/games/game_std'

        resource = @user
    # @needs_rated = current_user.unrated_users.all.count > 0 ? true : false
    @needs_rated = false # temporarily disabling


        # @games = ContractGameGameSystemJoin.select('"game_game_system_joins"."game_id"').
   #            joins(:game_game_system_join).group('"game_game_system_joins"."game_id"').
   #            order('count_game_game_system_joins_game_id DESC').
   #            count('"game_game_system_joins"."game_id"').
   #            map{|gid, um| Game.find gid}

   #  @users = User.all.order(contracts_completed: :desc).order(psa_rating: :desc)


   # NEW STREAM

   #upcoming events
   @upcoming_events = []#current_user.upcoming_events.order("start_date_time ASC").first(5)

   @invited_rosters = current_user.invites.where('status' => 0).map{|r| [r.contract_id]}
   @invites = Roster.where('id' => @invited_rosters).where('start_date_time > now()').order("start_date_time ASC").limit(5)

   #available players

   # Trending Games
   @trending_games = ContractGameGameSystemJoin.
               where('contract_game_game_system_joins.created_at > ?', Date.today - 3.month).
               select('"game_game_system_joins"."game_id"').
               joins(:game_game_system_join).group('"game_game_system_joins"."game_id"').limit(4).
               order('count_game_game_system_joins_game_id DESC').
               count('"game_game_system_joins"."game_id"').
               map{|gid, um| Game.find gid}




   # TODO: Should be any players with availability posted in the near future (or now?) that have the most popular game of @user?
   @available_players = User.all.limit(10)

   #my games
   # TODO: Should pick the user's most popular games
   @my_games = @user.my_games

   # relevant public events
   @relevant_events = Roster.eligible_bounties_with_my_games( current_user ).order(id: :desc).limit(4)

   #clans
   #TODO: Order this by most clan members - and active (has events in the recent past / future events)
   @clans = Clan.joins(:rosters).where('contracts.start_date_time > ?', Date.today - 1.month).
                  joins(:clan_members).group('clans.id').limit(4).order('count(clan_members.id) desc').reverse


   @user_clans = current_user.get_clans
   @clan_games = current_user.clans.map{|c| c.games}.flatten

   @clan_notices = ClanNotice.get_user_notices current_user
   @system_notices = SystemNotice.current

   @notices = Array.new
   @notices_grouped = Array.new
   @messages = current_user.mailbox.inbox(read: false)
   @notices_grouped.push(@clan_notices) unless @clan_notices.empty?
   @notices_grouped.push(@system_notices) unless @system_notices.empty?
   @notices_grouped.push(@messages) unless @messages.empty?
   @notices_grouped.flatten!

   @notices = @notices_grouped.sort_by{ |n| n.updated_at }.reverse.take(5)

   #trending
   @trending = nil;

   #coming soon
   # Need to find out the proper sorting scheme for these.
   # Since box is small how can we mix with upcoming & newly released?
   games = []#Game.all
   # @ordered_games_release = games.order("release_date asc")
   # @ordered_games_creation = games.order("created_at desc")
   # @coming_soon = @ordered_games_release.select{ |g| g.release_date != nil && g.release_date > Date.today }[0..4]
   # @new_games = @ordered_games_release.select{ |g| g.release_date != nil && g.release_date <= Date.today }[0..4]

   # Using created at since we don't have release dates
   @coming_soon = []#games.where('release_date > ?', Date.today).order("release_date asc").limit(4)
   @new_games = Game.where("created_at <= ?", Time.now).order("created_at desc").limit(4)
   # if @new_games.count < 5
   #   @ordered_games_creation.each do |g|
   #     # This block should only be reached if there's not enough
   #     # games with release dates so we should move onto the next
   #     # game in the list instead of tacking on misc upcoming games.
   #     @new_games << g if g.release_date.nil?
   #     break if @new_games.count == 5
   #   end
   # end

   #now playing
   @now_playing = User.all.limit(5)

   #@streaming_users = TwitchAPI.find_streaming_users
   if @streaming_users
     @streaming_counter = browser.device.mobile? ? 0 : 1
     @streaming_max = @streaming_users.count >= 2 ? 2 : @streaming_users.count
     @streaming_stop = @streaming_users.count
     @streaming_stop -= 1 if @streaming_counter == 0
   end
=end
  end

  def add_game_modal
    if params[:game_id]
      @game = Game.where(:id => params[:game_id]).last
      @system_ids_for_game = current_user.get_systems_for_game @game.id
      @system_names_for_game = @system_ids_for_game.map{ |g| GameSystem.find(g).title }
    end
  end

  def test
    @recurring = RecurringEvent.where(:game_game_system_join_id => '228').to_a
  end
end
