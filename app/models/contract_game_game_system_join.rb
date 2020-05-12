class ContractGameGameSystemJoin < ActiveRecord::Base
  belongs_to :contract
  belongs_to :game_game_system_join
  has_many :games, through: :game_game_system_join
  has_many :game_systems, through: :game_game_system_join


  delegate :game, to: :game_game_system_join
  delegate :game_system, to: :game_game_system_join
  delegate :game_cover, :game_jumbo, :game_mobile, :game_title,  to: :game
end
