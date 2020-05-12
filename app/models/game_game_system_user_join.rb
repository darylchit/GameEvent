class GameGameSystemUserJoin < ActiveRecord::Base
	belongs_to :game_game_system_join
	belongs_to :user
	has_many :games, through: :game_game_system_join
	has_many :game_systems, through: :game_game_system_join
end
