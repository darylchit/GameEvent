class ClanGame < ActiveRecord::Base
	belongs_to :game
	belongs_to :clan
end
