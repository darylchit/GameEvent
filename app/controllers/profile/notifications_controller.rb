class Profile::NotificationsController < InheritedResources::Base
	before_action :authenticate_user!

	defaults :resource_class => User

  def edit
		@box_type = 'Settings'
  end

  def update
    update!( notice: "Settings were successfully updated." ){ edit_profile_notifications_path }
  end

	private
    def permitted_params
			params.permit( user: [ :notif_site, :notif_system, :notif_push, :notif_sms, :notif_games, :notif_email, :notif_reminder ] )
    end

	protected
    def resource
      current_user
    end
end
