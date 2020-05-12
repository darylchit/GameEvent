class GameSystem < ActiveRecord::Base
	has_many :game_game_system_joins
	has_many :games, through: :game_game_system_joins
	has_and_belongs_to_many :clans

	validates :title, presence: { message: "Title is Required" }
	validates :abbreviation, presence: { message: "System Abbreviation is Required" }
end
