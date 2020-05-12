class Api::V1::Profile::NotificationsController < Profile::NotificationsController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Updates the notification settings for a user
  #
  # PUT /api/v1/profile/notifications
  #
  # @param user [Hash]
  #   - notif_site
  #   - notif_system
  #   - notif_games
  #   - notif_push
  #   - notif_sms
  def update
    resource.update_attributes permitted_params[:user]
    if !resource.valid?
      render json: resource.errors, status: :unprocessable_entity
    else
      resource.save
      respond_with json: {}, status: :ok
    end
  end
end
