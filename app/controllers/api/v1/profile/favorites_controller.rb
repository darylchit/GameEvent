class Api::V1::Profile::FavoritesController < Profile::FavoritesController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Lists the user's favorited users
  #
  # GET /api/v1/profile/favorites
  #
  # @return [Array<Favorite>]
  #   * id **(Int)** - Favorite ID
  #   * favorited_user **({User})** - The user that is favorited
  def index
    respond_with collection, each_serializer: Api::V1::FavoriteSerializer
  end

  # Creates a new favorited user
  #
  # POST /api/v1/profile/favorites
  #
  # @param favorite [Hash] required fields: `favorited_user_id`
  #
  # @return [Favorite]
  def create
    build_resource
    if resource.valid?
      if resource.favorited_user.present? && is_valid_favorite(resource.favorited_user)
        resource.save
        render json: resource, serializer: Api::V1::FavoriteSerializer
      else
        render json: [{'error':'Unable to favorite this user'}], status: :unprocessable_entity
      end
    else
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  # Unfavorites a user
  #
  # DELETE /api/v1/profile/favorites/:id
  #
  # @param id [Int] the favorite ID
  #
  # @return `200` if successful
  def destroy
    resource.destroy
    render json: {success: true}, status: :ok
  end
end
