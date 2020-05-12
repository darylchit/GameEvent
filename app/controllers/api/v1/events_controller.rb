class Api::V1::EventsController < EventsController
  respond_to :json
  protect_from_forgery with: :null_session
  skip_before_filter :authenticate_user!
  skip_before_filter :set_upcoming_events
  acts_as_token_authentication_handler_for User

  # Get the list of upcoming events that a user has created or has been invited to
  #
  # GET /api/v1/my-events
  #
  # @return [Array<Contract>] events
  def index
    set_upcoming_events
    respond_with @upcoming_events, each_serializer: Api::V1::CompactContractSerializer, :current_user => current_user
  end

end
