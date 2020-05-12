class GameGameSystemJoin < ActiveRecord::Base
	belongs_to :game_system
	belongs_to :game
	has_many :events
	has_many :recurring_events

	delegate :game_cover, :game_jumbo, :game_jumbo_mobile, :title, to: :game, allow_nil: true

	scope :active_games, -> { joins(:game).where('games.active = ?', true) }

	#useful in the contract post page
	def game_system_name_label
		"#{game.title} - #{game_system.abbreviation}"
	end

	def game_title
		title
	end

end
