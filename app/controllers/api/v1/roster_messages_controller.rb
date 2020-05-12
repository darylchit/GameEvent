class Api::V1::RosterMessagesController < RosterMessagesController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session
  before_action :check_if_owner, except: [:create, :index]
  skip_before_filter :ensure_user_can_post

  # Lists the messages posted to a roster
  #
  # GET /api/v1/rosters/:id/roster_messages
  #
  # @param id [Int] the roster ID
  # @return [Array<RosterMessage>] an array of {RosterMessage}s
  def index
    # make sure we have a roster id
    unless params[:roster_id].present?
      return render json: {}, status: :not_found
    end
    # make sure we have a valid roster that the user can view
    roster = Roster.where(:contract_type => 'Roster').find_by_id params[:roster_id]
    unless roster.present?
      return render json: {}, status: :not_found
    end
    # for a private roster, the user must be invited
    if roster.private? && !roster.invited?(current_user) && roster.owner != current_user
      return render json: {}, status: :not_found
    end

    # user has access to view the messages

    respond_with roster.roster_messages, each_serializer: Api::V1::RosterMessageSerializer
  end

  # Posts a new message to a roster
  #
  # POST /api/v1/rosters/:id/roster_message
  #
  # @param id [Int] the roster ID
  # @param roster_message [Hash]
  #   * message **(String)** the message body
  # @return [RosterMessage] `201` the created {RosterMessage} if successful
  # @return [Array] `422` an array of errors keyed on the field name
  def create
    message = params[:roster_message][:message]

    unless message.present?
      return render json: {}, status: :unprocessable_entity
    end
    # since we're skipping the validation for checking that a user can post (current_user is nil for some reason),
    # we need to manually check
    # make sure we have a roster id
    unless params[:roster_id].present?
      return render json: {}, status: :not_found
    end
    # make sure we have a valid roster that the user can chat in
    roster = Roster.where(:contract_type => 'Roster').find_by_id params[:roster_id]
    unless roster.present?
      return render json: {}, status: :not_found
    end
    # for any roster, the user must be invited (an invite is created when a spot is claimed in a public event)
    if !roster.invited?(current_user) && roster.owner != current_user
      return render json: {}, status: :not_found
    end

    roster_message = current_user.roster_messages.new(message: message, roster_id: params[:roster_id])
    if roster_message.save
      notify_users roster_message
      respond_with roster_message, serializer: Api::V1::RosterMessageSerializer
    else
      return render json: roster_message.errors, status: :unprocessable_entity
    end
  end
end
