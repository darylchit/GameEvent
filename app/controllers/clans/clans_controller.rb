class Clans::ClansController < ApplicationController
	include SortsAndFilters
	include DiscordBot

	before_action { flash.clear }
	before_action :clan, except: [:new, :create, :index, :confirmation]
	before_filter :authenticate_user!, :except =>[:index, :show, :clan_share]
	before_filter :is_owner, only: [:update, :destroy, :edit, :change_owner, :clan_members_update, :unblock_member]
	before_filter :get_collection, only: [:index]
	before_filter :filter_params, only: [:index]
	before_filter :set_search, only: [:index]
	before_filter :get_clan_form_data, only: [:edit]
	before_filter :clan_already_created?, only: [:new]
  before_filter :is_premium?, only: :new

	respond_to :html, :js

	expose :user_games, :build_games
	expose :recurring_event do
		RecurringEvent.new
	end
  expose :clan do
    Clan.friendly.find(params[:clan_id])
  end
	expose :recurring_events do
		clan.recurring_events
	end

	def show
		set_all_tabs
		if @clan.present?
			@set_offset = 25
			@clan_messages_count = @clan.clan_messages.count
			@notice = Notice.new
			# if not resource.is_member? current_user
			@total_game_systems = GameSystem.count
			invites = ClanInvite.where(user: current_user).where(status: "pending")
			@clan_invite = nil
			invites.each do |i|
				@clan_invite = i
				if not @clan_invite.is_request? then break end
			end

			@events = Event.clan_event.where(clan_id: @clan).future_events.not_cancelled.event_start_order#.page(params[:page]).per(3)
			@events_count = @events.count if @events

			#TODO: Calculate the clan's most active user somehow?
			@most_active = User.where(:id => @clan.most_active).first
			@clan_applications = @clan.clan_applications
			@clan_applications_count = @clan_applications.count
			@set_offset = 10
	    @clan = clan
			if clan.recruiting? && current_user.present?
			 	@pending_application = current_user.clan_applications.find_by_clan_id(clan.id)
			  @deleted_application = current_user.clan_applications.deleted.find_by_clan_id_and_status(clan.id, false)
			end
			@clan_member = clan.active_member? current_user if current_user.present?

			# if @clan_member
			# 	flash[:toster] = "Welcome To #{@clan.name}. You Are Now A Rank 3 Member."
			# else
			# 	flash[:toster] = "You Are No Longer A Member of #{@clan.name}."
			# end
			# @events = @clan.rosters
	    @clan_notices = clan.clan_notices.current
	    # @twitch_stream = TwitchAPI.user_stream @clan
			@clan_donation = @clan.clan_donations.new
		else
			redirect_to clans_path
		end
	end

	def index
		@timezones = ActiveSupport::TimeZone.all.map{|tz| tz.name}
		@games = GameGameSystemJoin.all

		@sorted_games = Game.active.sort_by &:title
		@sorted_systems = GameSystem.all.sort_by &:title
		@total_game_systems = GameSystem.count
		# @resource = @resource.reject {|r| r.clan_members.count.between?()}
    if @range_params.any? && @range_params["members"].any?
      @resource = @resource.joins(:clan_members).group("clans.id").having("count(clan_members.id) >= ? and count(clan_members.id) <= ?", @range_params["members"][0].to_i, @range_params["members"][1].to_i)
    end

    # if @sort_params.any? && @sort_params["alphabetical_sort"].present? && @sort_params["alphabetical_sort"]["Member Size"]
    # 	@resource = @resource.select("clans.*, COUNT(clan_members.id) as member_count").joins("LEFT OUTER JOIN clan_members ON (clan_members.clan_id = clans.id)").where("clan_members.deleted_at is NULL ").group("clans.id").reorder('member_count desc')
    # end
    # if @sort_params.any? && @sort_params["alphabetical_sort"].present? && @sort_params["alphabetical_sort"]["Most Posted Events"]
    # 	@resource = @resource.select("clans.*, COUNT(events.id) as clans.event_count").joins("LEFT OUTER JOIN events ON (events.clan_id = clans.id)").where('events.end_at >= ?', DateTime.now).group("clans.id").reorder('clans.event_count desc')
    # end

    if params[:my_clans] && eval(params[:my_clans])
      @clans = @resource.joins(:clan_members).where('clan_members.user_id': current_user.id)
    else
      @clans = @resource
		end

		@clans = set_order(@clans)
		@clans = @clans.page(params[:page]).per(30)
    respond_to do |format|
    	format.js
    	format.html
    end
  end

  def new
  	@timezones = ActiveSupport::TimeZone.all.map{|tz| tz.name}
    @sorted_systems = GameSystem.all
    @clan = Clan.new
		3.times {|i| @clan.clan_ranks.build}
		@clan.links.build
		@clan.video_urls.build
    @games = Game.all.order('title ASC')
  end

  def create
  	if params[:clan][:game_system_ids].uniq.count != params[:clan][:game_system_ids].count
  		params[:clan][:game_system_ids] = GameSystem.ids.map(&:to_s)
		end
		@timezones = ActiveSupport::TimeZone.all.map{|tz| tz.name}
		@sorted_systems = GameSystem.all
		unless params[:clan][:status] == "recruiting"
		  params[:clan].delete("questions_attributes") if params[:clan][:questions_attributes]
		end
		@clan = Clan.new(clan_params)
    @clan.assign_attributes(host_id: current_user.id)

    # if @clan.save
    #   redirect_to clan_path(@clan)
    # else
    #   flash[:danger] = "Failed to create clan"
    #   redirect_to root_url
    # end

    respond_to do |format|
      if @clan.save
				flash[:toster] = "Congratulations! Your Clan is Now Available."
        format.html { redirect_to confirmation_clans_path }
        format.json { render json: @clan, status: :created, location: @clan }
      else
        @games = Game.all
        format.html { render action: 'new' }
        format.json { render json: @clan.errors, status: :unprocessable_entity }
      end
    end

  end

	def confirmation
		@clan = current_user.own_clan
		if @clan.present?
			@clan_mail = AdminConfig.clan_create_email
		else
			redirect_to clans_path
		end

	end

  def edit
  	@favorite_users = current_user.favorites
    @clan_applications = @clan.clan_applications.includes(:user => :system_avatar, :answers => [:question])
    @clan_applications_count = @clan.clan_applications.count
    @set_offset = 10
		respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def update
    @clan_applications = @clan.clan_applications.includes(:user => :system_avatar, :answers => [:question])
  	@clan_applications_count = @clan.clan_applications.count
    @set_offset = 10
		if params[:clan][:game_system_ids].uniq.count != params[:clan][:game_system_ids].count
  		params[:clan][:game_system_ids] = GameSystem.ids.map(&:to_s)
		end
		unless params[:clan][:status] == "recruiting"
		  params[:clan].delete("questions_attributes") if params[:clan][:questions_attributes]
		end
    if @clan.update(clan_params)
      flash[:toster] = "Clan Updated"
			redirect_to edit_clan_path(@clan)
		else
			get_clan_form_data
			render action: :edit
    end

  end

	def change_owner
		if params[:change_clan_owner] == "transfer".upcase && clan_host_params[:host_id].present?
			clan_receiver_user = User.find(clan_host_params[:host_id])
			# TODO RAJNIK
			# if clan_receiver_user.active_subscription.present?  && clan_receiver_user.active_subscription.elite? && clan_receiver_user.own_clan.nil? && @clan.update(clan_host_params)
			if clan_receiver_user.own_clan.nil? && @clan.update(clan_host_params)
        @clan.clan_members.find_or_create_by(user_id: clan_receiver_user.id)
				@updated = true
			else
				@updated = false
			end
		end
		respond_to do |format|
      format.js
    end
	end

  def destroy
    if @clan.destroy
      flash[:info] = "Clan destroyed"
      redirect_to clans_path
    end

  end

  def join
    @clan = resource
    @clan.join current_user
  end

	def remove_member
		clan_member = @clan.clan_members.find(params[:clan_member_id])
		clan_member.destroy if clan_member.present?
		render nothing: true
	end

	def unblock_member
		clan_member = @clan.clan_members.with_deleted.find(params[:clan_member_id])
		clan_member.really_destroy! if clan_member.present?
		@clan_member_id =  params[:clan_member_id]
		@total_banned = @clan.clan_members.with_deleted.count
		# render nothing: true
		respond_to do |format|
          format.js
        end
	end

	def clan_members_update
		clan_member = @clan.clan_members.find(params[:clan_member_id])
		clan_member.update(clan_member_params)
		render nothing: true
	end

	def get_messages
		@offset = params[:offset]
		@offset_add = params[:offset].to_i + 25
		@clan_id = params[:id]
		@total = params[:total_message].to_i
		@show_button = false
		if (@offset_add >= @total)
			@show_button = true
		end
		respond_to do |format|
			format.js
		end
	end

	def get_pending_clan_applications
		@offset = params[:offset]
		@offset_add = params[:offset].to_i + 10
		@clan_id = params[:id]
		@total = params[:total_applications].to_i
		@show_button = false
		if (@offset_add >= @total)
			@show_button = true
		end
		respond_to do |format|
			format.js
		end
	end

	def get_blocked_clan_members
		@offset = params[:offset]
		@offset_add = params[:offset].to_i + 10
		@clan_id = params[:id]
		@clan = Clan.find(params[:id])
		@blocked_members = @clan.clan_members.deleted.preload(:user,:clan_rank).where('user_id != ?', @clan.host_id).order(:created_at) rescue nil
		@total = params[:total_blocked].to_i
		@show_button = false
		if (@offset_add >= @total)
			@show_button = true
		end
		respond_to do |format|
			format.js
		end
	end

	def delete_confirmation
	end

	def delete_clan
		if params[:remove_string] == "remove".upcase
			@clan.update_attributes(deleted_at: Time.now)
			respond_to do |format|
				format.js
			end
		else
			respond_to do |format|
				format.js { render "delete_confirmation" }
			end

		end
	end

	def reactivate_clan
		#TODO RAJNIK
		clan = Clan.with_deleted.find(@clan.id)
		# if current_user.active_subscription
			clan.restore
		# end
	end

	def my_clans
	end

	def clan_share
	end

	def get_more_clan_events_on_scrolling
		@events = Event.clan_event.where(clan_id: @clan.id).future_events.not_cancelled.page(params[:page]).per(3)
	end

	def discord_channels
		@channels, @server, @account = get_channels(current_user)
		@discord_authorize = current_user.authorizations.discord.last
	end

	def discord_data
		@discord_authorize = current_user.authorizations.discord.last
		@discord_authorize.update_attributes(discord_channels: params[:channels], alert_all: params[:alert_all], discord_event_notification: params[:discord_event_notification], no_event_posted: params[:no_event_posted], daily_clan_summary: params[:daily_clan_summary] )
	end

	def discord_reset
		authorizations =  current_user.authorizations.discord
		authorizations.update_all(guild_id: nil, discord_channels: nil) if authorizations.present?
		flash[:error] = "Discord Configuration Removed"
		# redirect_to edit_clan_path(@clan)
	end

 	private

 		def clan_already_created?
 			if current_user.clans.pluck(:host_id).include?(current_user.id)
 				flash[:error] = "You have already create clans"
 				redirect_to clans_path
 			end
 		end

    def clan
      @clan = Clan.with_deleted.friendly.find(params[:id] || params[:clan_id])  if Clan.with_deleted.present?
    end

    def is_owner
      unless clan.is_host? current_user
        flash[:error] = "You are not the clan owner"
        redirect_to clan
      end
    end

    def get_collection
			clans = Clan.all
			# filter

			# Presort by what?
		 #@family_friendly = params[:family_friendly]
			#clans = clans.order(created_at: :asc)

			@resource = clans
    end

    def is_premium?
      # unless current_user.is_premium?
      #   flash[:error] = 'You must be a Elite member to host clans.'
      #   redirect_to profile_subscription_path unless current_user.is_premium?
      # end
    end

    def clan_params
      params.require(:clan).permit(:name, :game_type, :game_system, :play_style,
        :languages, :timezone, :bio, :minimum_age, :family_friendly, :availability, :ground_rules, :cover, :jumbo,
        :mobile_jumbo, :private, :autojoin, :facebook, :youtube, :twitter, :twitch, :bungie, :discord, :youtube_video_url, :battlelog, :legend, :slack,
        :jumbo_cache, :mobile_jumbo_cache, :cover_cache, :motto, :requirements, :paypal_email, :remove_inactive_users,
				:country, :status, :google, :instagram, :curse, :patreon, :steam, :reddit, :mlg,
				:discord_invitation, :scuf, :wargaming, :battle, :skype, :mixer_url, :apply_email, :join_email,
				:annual_dues, :annual_dues_amount, :re_apply, :most_active, :most_active_days,
				:access_code, :languages => [],  :clan_game_systems => [],
				links_attributes: [:id, :name, :url, :_destroy],
				video_urls_attributes: [:id, :name, :url, :_destroy],
				game_ids: [], game_system_ids: [],
				clan_ranks_attributes: [:id, :title, :post_events, :post_chat, :post_notices, :review_applications, :is_default, :receive_contact, :default_sort_order],
				questions_attributes: [:id, :name, :_destroy])
    end

		def clan_host_params
			params.require(:clan).permit(:host_id)
		end

		def clan_member_params
			params.require(:clan_member).permit(:clan_rank_id)
		end

		def get_clan_form_data
			@timezones = ActiveSupport::TimeZone.all.map{|tz| tz.name}
	    @sorted_systems = GameSystem.all
	    @games = Game.all.order('title ASC')
			@clan_members = @clan.clan_members.preload(:user, :clan_rank).where('user_id != ?', @clan.host_id).order(:created_at).page(params[:page]).per(50) rescue nil
			@blocked_members = @clan.clan_members.deleted.preload(:user,:clan_rank).where('user_id != ?', @clan.host_id).order(:created_at) rescue nil
		end

  def set_all_tabs
    @tabs = [
      # {id: "clan-about", display: "About", path: "/clans/clans/about", icon: "fa-info-circle"},
      {id: "clan-specs", display: "Specs", path: "/clans/clans/specs", icon: "fa-list-alt"},
      {id: "clan-links", display: "Links", path: "/clans/clans/links", icon: "fa-link"},
      {id: "clan-videos", display: "Videos", path: "/clans/clans/videos", icon: "fa-video-camera"},
      # {id: "clan-members", display: "Members", path: "/clans/clans/members", icon: "fa-users"},
      {id: "clan-application", display: false, path: false, icon: false}
      # {id: "clan_applications_modal", display: "Applications", path: "/clans/clan_applications/applications_modal", icon: "fa-file-text", data: { toggle: "modal", target: "#clan_applications_modal"}},
    ]
	end

	def set_order(clans)
		clans = if params[:sort_filter].present? && params[:sort_filter] == 'name_asc'
							clans.order('clans.name')

            elsif params[:sort_filter].present? && params[:sort_filter] == 'name_desc'
										clans.order('clans.name desc')


					 elsif  params[:sort_filter].present? && params[:sort_filter] == 'member_size'
						 Clan.joins('LEFT JOIN clan_members ON clans.id = clan_members.clan_id').where('clans.id in (?)', clans.ids)
								 .group(:id)
								 .order('COUNT(clan_members.id) DESC,  clans.id ASC')

						else
							Clan.includes(:clans_game_systems, :clan_avatar).where('clans.id in (?)', clans.ids)
									.order('activity_score desc NULLS LAST')


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
  end

end
