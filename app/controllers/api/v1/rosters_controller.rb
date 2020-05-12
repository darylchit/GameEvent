class Api::V1::RostersController < RostersController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  def index
    respond_with collection, each_serializer: Api::V1::CompactRosterSerializer
  end

  # Details of a Roster
  # GET /api/v1/rosters/:id
  #
  # @param [Int] id
  # @return [Roster] the roster with the provided id
  def show
    @roster = Roster.where(contract_type: 'Roster').find( params[:id] )

    # Private rosters are only visible to invited users
    if @roster.private?
      @roster = current_user.all_rosters.find( params[:id] )
    end
    respond_with @roster, serializer: Api::V1::ContractSerializer, current_user: current_user
  end

  # Creates a new roster and assigns it to the current user as the seller
  #
  # @param roster [Roster] required fields: `title`, `start_date_time`, `duration`, `game_game_system_join_ids`,
  #     `private`, `play_type`, `will_play`, `max_roster_size`, `waitlist`
  #
  # @return [Contract] `201` the created contract if successful
  # @return [Array] `422` an array of errors keyed on the field name
  #
  def create
    build_resource
    unless resource.save
      return render json: resource.errors, status: :unprocessable_entity
    end

    notify_users []
    NotificationWorker.perform_async(resource.id, 'Roster', 'Notifications::RosterNotification', 'send_notification')
    respond_with resource, serializer: Api::V1::ContractSerializer
  end

  def update
    before_user_ids = resource.users.ids

    unless update_resource( resource,  resource_params )
      return render json: resource.errors, status: :unprocessable_entity
    end

    notify_users before_user_ids if resource.status == 'Open'

    if resource.previous_changes.key?(:start_date_time)
      resrouce.roster.remove_confirmed_and_waitlist
      notify_time_update
    end

    respond_with resource, serializer: Api::V1::ContractSerializer
  end

  # Cancels a roster
  #
  # DELETE /api/v1/rosters/:id
  #
  # @param id [Int] the roster ID
  #
  # @return [Hash] success
  def destroy
    resource.cancelled!
    render json: { success: true }, status: :ok
  end

  private

  def not_found
    # when scope prevents finding the object, in other words
    # user does not have permission to get view this
    self.status = :unauthorized
    self.response_body = { error: 'Access denied' }.to_json
  end

  def permitted_params
    if params['contract']
      params['roster'] = params['contract']
    end
    # NOTE: non-api-specific changes here should be made in RosterController as well
    if params[:roster] and params[:roster][:user_ids] and params[:roster][:user_ids].is_a?(String)
      params[:roster][:user_ids]  = params[:roster][:user_ids].split(/[^\d]+/)
    end
    if params[:roster] && params[:roster][:game_game_system_join_ids] && params[:roster][:game_game_system_join_ids].is_a?(Array)
      params[:roster][:game_game_system_join_ids] = params[:roster][:game_game_system_join_ids][0] if params[:roster][:game_game_system_join_ids].length > 0
    end
    params.permit(roster: [ :title, :details, :game_game_system_join_ids, :duration, :start_date_time, :will_play, :private, :play_type, :duration, :max_roster_size, :waitlist, user_ids:[] ])
  end
end
