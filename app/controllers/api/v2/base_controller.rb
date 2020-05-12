class Api::V2::BaseController < ApplicationController
  respond_to :json

  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User

  around_filter :set_timezone
end
