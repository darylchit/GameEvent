class Api::V1::Contracts::ClaimedContractsController < Contracts::ClaimedContractsController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Cancels a contract that you have claimed
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
