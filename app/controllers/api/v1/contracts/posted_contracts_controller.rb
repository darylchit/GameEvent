class Api::V1::Contracts::PostedContractsController < Contracts::PostedContractsController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Creates a new contract and assigns it to the current user as the seller
  #
  # @param contract [Contract] required fields: `start_date_time`, `duration`, `game_game_system_join_ids[]`,
  #     `price_in_dollars`, `play_type`, `will_play`
  #
  # @return [Contract] `201` the created contract if successful
  # @return [Array] `422` an array of errors keyed on the field name
  #
  def create
    build_resource
    resource.seller = current_user
    if !resource.valid?
      render json: resource.errors, status: :unprocessable_entity
    else
      resource.status = 'Open'
      resource.save
      respond_with resource, serializer: Api::V1::ContractSerializer
    end
  end

  # Updates a contract
  #
  # PUT /api/v1/my-posted-events/:id
  #
  # @params id [Int] contract ID
  # @param contract [Contract] required fields: `start_date_time`, `duration`, `game_game_system_join_ids[]`,
  #     `price_in_dollars`, `play_type`, `will_play`
  # @return `204` if the contract was updated
  # @return [Array] `422` an array of errors keys on the field name
  def update
    # build_resource
    if resource.status == 'Open'
      resource.update_attributes permitted_params[:contract]
      if !resource.valid?
        render json: resource.errors, status: :unprocessable_entity
      else
        resource.save
        respond_with json: {}, status: :ok
      end
    else
      respond_with json: [{'error':'The contract must be Open to edit.'}], status: :unprocessable_entity
    end
  end

  # Cancels a contract that you have posted
  #
  # DELETE /api/v1/my-claimed-events/:id
  #
  # @param id [Integer] contract ID
  # @param contract [Hash]
  #   - cancellation_reason **(String)** required
  #   - cancellation_note **(String)** optional
  # @return `200` success if it was cancelled
  def destroy
    cancel_contract!
    render json: { success: true }, status: :ok
  end
end
