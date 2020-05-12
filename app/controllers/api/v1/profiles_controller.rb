class Api::V1::ProfilesController < ProfilesController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Gets the detail of a user for viewing their profile
  #
  # GET /api/v1/profiles/:username
  #
  # @param username [String] username of the user
  # @return [User]
  #   * **also includes:**
  #   * is_favorited **(Boolean)**
  #   * is_blocked **(Boolean)**
  #   * events **(Array)** an array of Contracts, {Bounties, or Rosters
  def show
    user = User.find_by_username(params[:id])

		if !user.present?
			return render json: {}, status: :not_found
		end

    respond_with user, serializer: Api::V1::UserProfileSerializer, :current_user => current_user, :events => user_contracts.where('start_date_time > NOW()').order(:start_date_time)
  end
end
