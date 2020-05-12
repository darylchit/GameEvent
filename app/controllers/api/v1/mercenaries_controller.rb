class Api::V1::MercenariesController < MercenariesController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Searches for users that match the search parameter. This will not include current_user
  #
  # GET /api/v1/search
  #
  # @param username [String] the username to search for (required, minimum 3 characters)
  # @return [Array<User>] `users` an array of {User}s
  def index
    if params[:username].present?
      if params[:username].length >= 3
        users = User.where("username ILIKE ?", "%#{params[:username]}%").where(deleted_account: false)
        users = users.where.not id: current_user.id if current_user.present?
        respond_with users, each_serializer: Api::V1::UserSerializer, root: 'users'
      else
        render json: { message: 'Username must be at least 3 characters' }, status: :unprocessable_entity
      end
    else
      render json: {}, status: :not_found
    end
  end
end
