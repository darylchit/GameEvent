class Api::V2::FavoritesController < ApplicationController
  respond_to :json

  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User

  expose :favorites do
    current_user.favorited_users
  end

  expose :clans do
    current_user.clans
  end

  def create
    if params[:favorites].present? && params[:favorites].is_a?(Hash)
      params[:favorites].each do|username, user_id|
        user = User.find_by_id_and_username(user_id, username)
        current_user.favorites.find_or_create_by(favorited_user_id: user.id) if user.present?
      end
    end
    render :index
  end

end
