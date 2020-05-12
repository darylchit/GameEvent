class Api::BaseController < InheritedResources::Base
  respond_to :json
  protect_from_forgery with: :null_session

  rescue_from StandardError do |exception|
    render json:  { error: exception.message, status: 500 }
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json:  { error: exception.message, status: 404 }
  end
end
