class RosterInvitesController < ApplicationController
	before_filter :authenticate_user!
	before_filter :get_resource
	respond_to :html, :js

  def create
    before_user_ids = @roster.users.ids    
    unless @roster.invited?(@user) 
     @roster.users << @user
     notify_users before_user_ids 
     respond_to do |format|
          format.html {}
          format.js {render :layout => false}
       end
     else 
      respond_to do |format| 
        format.html {}
        format.js{ render "errors.js.erb", :status => 422}
     end
    end
  end

  private

  def get_resource
    @user = User.find(params[:user_id])
    @roster = Roster.find(params[:roster_id])
  end

  #taken from rosters controller 
  def notify_users before_user_ids
    users_removed = before_user_ids - @roster.users.ids
    users_added   = @roster.users.ids - before_user_ids

    # users added
    User.find(users_added).each do | u |
      @roster.send_welcome_message u
      i = @roster.invites.find_by :user => u
      NotificationWorker.perform_async(i.id, 'Invite', 'Notifications::EventInviteNotification', 'invited') if i.present?
    end

    # users removed
    User.find(users_removed).each do | u |
      @roster.send_removed_message u
    end
  end



end
