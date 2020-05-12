class RatingsController < ApplicationController
	before_filter :authenticate_user!
  before_filter :set_user, only: [ :create ]

  expose :rateable_users do
    current_user.unrated_users
  end

  expose :rated_users do
    current_user.rated_users
  end


	respond_to :js

  def index
    
  end

  def create
    @rating = current_user.ratings.find_by( rated_user: @user ) || current_user.ratings.build( rated_user: @user)
    upsert
  end

  def update
    @rating =  current_user.ratings.find( params[:id] )
    upsert
  end

  def upsert
    @rating.update_attributes( permitted_params )
    @rating.save
    @rating.rated_user.update_rating!
    render :upsert
  end

  private 

	def permitted_params
    params.require(:rating).permit(:personality, :skill, :respect, :comment)
  end

  def set_user
    @user = User.find(params[:profile_id])
  end
end
