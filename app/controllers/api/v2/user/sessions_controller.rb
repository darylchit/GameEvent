class Api::V2::User::SessionsController < Devise::SessionsController
  respond_to :json
  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User
  ##
  # Authenticate a user with an email and password returning a user object.
  #
  # POST /api/v1/user/session
  #
  # params:
  #   email - email address
  #   password - password
  #
  # From this point the email and authentication_token from the user object returned is expected
  # to be passed in the header of all subsequent requests:
  #
  # X-User-Token: user.authentication_token
  # X-User-Email: user.email
  #
  # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/sessions_controller.rb
  #
  def create
    self.resource = warden.authenticate!(auth_options)
    if params[:user].present? && params[:user][:type].present? && ['0','1'].include?(params[:user][:type]) && params[:user][:fcm_token].present?
     sign_in(resource_name, resource)
     user_setting = current_user.user_setting
     app_type = params[:user][:type] == '0' ? 0 : 1
     @user_setting =  user_setting.update_attributes(app_type: app_type, fcm_token: params[:user][:fcm_token])
    end

    # @user = current_user
    # respond_with(@user)
    # respond_to do |format|
    #   format.json {
    #     render :json => {
    #         :user => Api::V1::LoginUserSerializer.new(current_user, root: false),
    #         :status => :ok,
    #         :authentication_token => current_user.authentication_token
    #     }
    #   }
    # end
  end

end
