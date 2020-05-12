class Api::V1::User::SessionsController < Devise::SessionsController
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
    sign_in(resource_name, resource)
    respond_to do |format|
      format.json {
        render :json => {
          :user => Api::V1::LoginUserSerializer.new(current_user, root: false),
          :status => :ok,
          :authentication_token => current_user.authentication_token
        }
      }
    end
  end

  ##
  # log a user out.
  #
  # DELETE /api/v1/user/session
  #
  # params:
  #
  # current does nothing, since removing the api token would effectively
  # logout a user from all devices.
  #
  def destroy

   respond_to do |format|
     format.json {
       if user_signed_in?
         render :json => {}.to_json, :status => :ok
       else
         render :json => {}.to_json, :status => 401
       end
     }
   end
  end
end
