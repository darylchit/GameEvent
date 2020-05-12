class Api::V2::User::PasswordsController < Devise::PasswordsController
  respond_to :json

  protect_from_forgery with: :null_session

  def create
    super
  end
end
