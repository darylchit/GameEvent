class Api::V1::Profile::BlocksController < Profile::BlocksController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Block a user
  #
  # POST /api/v1/profile/blocks
  #
  # @param block [Hash] required fields: `blocked_user_id`; optional fields: 'contract_id'
  #
  # @return [Block]
  def create
    build_resource
    if resource.valid?
      if resource.blocked_user.present? && resource.blocked_user != current_user
        resource.save
        render json: resource, serializer: Api::V1::BlockSerializer
      else
        render json: [{error: 'Unable to block this user'}], status: :unprocessable_entity
      end
    else
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  # Unblock a user
  #
  # DELETE /api/v1/profile/blocks/:id
  #
  # @param id [Int] the block ID
  #
  # @return `200` if successful
  def destroy
    resource.destroy
    render json: {success: true}, status: :ok
  end
end
