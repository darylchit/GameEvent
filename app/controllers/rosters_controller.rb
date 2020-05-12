class RostersController < InheritedResources::Base
	before_filter :authenticate_user!
	respond_to :html, :js

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

	def index
		@grid = initialize_grid(collection,
			order: 'start_date_time',
			order_direction: 'asc',
			per_page: 30,
			name: 'grid',
		)
		super
	end

  def show
    # ensure user either owns or has been invited to this event
		@roster = Roster.where(contract_type: 'Roster').find( params[:id] )

    # Private rosters are only visible to invited users
    if @roster.private?
      @roster = current_user.all_rosters.find( params[:id] )
    end

    @invite = current_user.invite_for @roster
    @roster_message = RosterMessage.new
    get_grids
  end

	def edit
		@games = eligible_games
   	@roster = Roster.find(resource.id)
    @roster_message = RosterMessage.new
    if resource.clan_id.present?
      @clan = Clan.where(:id => resource.clan_id).last
    end 
    get_grids
		super
	end

	def update
     @games = eligible_games
   	 @roster = resource
     @roster_message = RosterMessage.new
     get_grids
     before_user_ids = resource.users.ids
     if resource.status == 'Open'
			update!{
        notify_users before_user_ids
        edit_roster_path resource
      }
     end
     if resource.previous_changes.key?(:start_date_time)
            @roster.remove_confirmed_and_waitlist
            notify_time_update
     end
	end

	def new
		@games = eligible_games
	  @roster = build_resource
	  # set default roster size
	  @roster.max_roster_size = 2
		super
	end

  def invite_user
    @open_rosters = current_user.open_rosters
  end

	def add_invitees
    if params[:clan_id]
      @search_all_users = false
      @search_clan_users = true

      @clan = Clan.where(:id => params[:clan_id]).last

      # if we have an id we can load that roster
      @roster = params[:id].present? ? resource : build_resource

      # if we have an existing roster, ensure invited users are included in this list
      # even if they are not current favorites

      @users = @clan.users.where.not(:id => current_user.id)
      #.where(id: @roster.users.ids + current_user.favorited_users.ids)
    
    else
      # do we search favorites or all users?
      @search_all_users = params['search_all_users'].eql?('yes')

      # if we have an id we can load that roster
      @roster = params[:id].present? ? resource : build_resource

      # if we have an existing roster, ensure invited users are included in this list
      # even if they are not current favorites

      @users = if @search_all_users
        User.where.not(:id => current_user.blocked_by.map{|b| b.user_id}).where.not(:id => current_user.blocks.map{|b| b.blocked_user_id})
      else
        User.where(id: @roster.users.ids + current_user.favorited_users.ids)
      end
    end

    @invitees_grid = initialize_grid(@users,
      order: 'users.username',
      order_direction: 'asc',
      per_page: 30,
      name: 'grid',
      custom_order: {
        'users.username' => 'LOWER(users.username)'
      }
    )

	end

	def create
		@games = eligible_games
    create!{
      if resource.errors.empty?
        # notify_users []
        # NotificationWorker.perform_async(resource.id, 'Roster', 'Notifications::RosterNotification', 'send_notification')
        share_path(:id => resource.id, :priv => 'sup')
      end
    }
	end

  def cancel
    @roster = resource
  end

  def destroy
    @roster = resource
    @roster.cancelled!
    redirect_to events_path, success: "The Event has been cancelled"
  end

	private
		def permitted_params
			# NOTE: new fields added here should be added to the api RosterController as well

      # support passing a delimited string instead of dealing with arrays on the form
      # rails will work its magic when passed an array of ids for an association by adding and removing
      # the appropriate relationships
      if params[:roster] and params[:roster][:user_ids] and params[:roster][:user_ids].is_a?(String)
        params[:roster][:user_ids]  = params[:roster][:user_ids].split(/[^\d]+/)
      end

      params.permit(roster: [ :title, :clan_id, :details, :game_game_system_join_ids, :duration, :start_date_time, :will_play, :private, :play_type, :duration, :max_roster_size, :waitlist, user_ids:[] ])
		end

    def eligible_games
      current_user.game_game_system_joins.select do |ggs|
        current_user.has_game_system? ggs.game_system
      end
    end

    def get_grids
			#no shows still displayed and can be toggled
			@roster_users = @roster.confirmed_users + @roster.no_show_users
			@waitlist_users = @roster.waitlist_users
    end

    def not_found
      # when scope prevents finding the object, in other words
      # user does not have permission to get view this
      redirect_to events_path, alert: "You do not have access to the requested event."
    end

    def notify_users before_user_ids
      users_removed = before_user_ids - resource.users.ids
      users_added   = resource.users.ids - before_user_ids

      # users added
      User.find(users_added).each do | u |
        resource.send_welcome_message u
				i = resource.invites.find_by :user => u
				NotificationWorker.perform_async(i.id, 'Invite', 'Notifications::EventInviteNotification', 'invited') if i.present?
      end

      # users removed
      User.find(users_removed).each do | u |
        resource.send_removed_message u
      end
    end

   def notify_time_update
       users = resource.users.ids
       User.find(users).each do |u|
           resource.send_time_change_message u
					 i = resource.invites.find_by :user => u
	 				 NotificationWorker.perform_async(i.id, 'Invite', 'Notifications::EventInviteNotification', 'time_changed') if i.present?
       end
   end

	protected
    def begin_of_association_chain
			current_user
    end
end
