class Api::V2::User::LogoutSessionsController < ApplicationController
  respond_to :json

  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User
  def logout
    if  current_user.present?
      user_setting = current_user.user_setting
      @user_setting = user_setting.update_attributes(app_type: nil, fcm_token: nil)
    end
  end
end
