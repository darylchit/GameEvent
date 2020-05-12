class Api::V1::InvitesController < InvitesController
  respond_to :json
  protect_from_forgery with: :null_session
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User

  # Gets all of the current users pending invites
  #
  # GET /api/v1/invites
  #
  # @return [Array<Invite>] `invites` and array of {Invite}s
  def index
    respond_with current_user.invites.pending.joins(:contract).where('contracts.start_date_time > NOW()').order(:created_at), each_serializer: Api::V1::InviteSerializer
  end

  # Join a public game, adding the current_user to the active roster, or to the waitlist
  #
  # POST /api/v1/rosters/:id/invites
  #
  # @param id [Int] roster ID
  # @return [Hash] `200` if successful
  # @return `422` if user was already invited (should use `claim` instead)
  def create
		roster = Roster.find params[:roster_id]
    unless roster.status == 'Open'
      render json: { message: 'This event is no longer open.' }, status: :unprocessable_entity
      return
    end
		create_new_invite!
    render json: { success: true }
  end

  # Confirm an invite and claim you spot
  #
  # PATCH /api/v1/invites/:id/claim
  #
  # @param id [Int] invite ID
  # @return `204` if successful
  def claim
		roster = resource.roster
    unless roster.status == 'Open'
      render json: { message: 'This event is no longer open.' }, status: :unprocessable_entity
      return
    end
    claim_spot!
    render json: { success: true }
  end

  # Decline an invite
  #
  # PATCH /api/v1/invites/:id/decline
  #
  # @param id [Int] invite ID
  # @return `204` if successful
  def decline
    decline_invite!
    render json: { success: true }
  end

  def destroy
    @roster = current_user.rosters.find(resource.roster.id)
    removed_user = resource.user
    resource.destroy
    render json: { success: true }
  end

end
