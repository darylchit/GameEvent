class Api::V1::GameGameSystemsController < Api::BaseController
  respond_to :json
  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User
  defaults :resource_class => GameGameSystemJoin

  # Gets the list of games and systems available
  #
  # GET /api/v1/game_game_systems
  #
  # @return [Array<GameGameSystemJoin>] `game_game_systems` unordered array of {GameGameSystemJoin}s
	def index
    respond_with collection, each_serializer: Api::V1::GameGameSystemJoinSerializer
	end
end
