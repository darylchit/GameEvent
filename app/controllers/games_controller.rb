class GamesController < ApplicationController
	before_filter :authenticate_user!, except: [:show, :lfg]
	expose :game
	def index
		@game_game_systems = {}
		current_user.game_game_system_joins.each do | ggs |
			if !@game_game_systems[ggs.game_id].present?
				@game_game_systems[ggs.game_id] = []
			end
			@game_game_systems[ggs.game_id] << ggs.game_system_id
		end

		@my_games = []
		taken_games = []
		current_user.games.uniq.each do | g |
			@my_games << g
			taken_games << g.id
		end

		@games = Game.all
		@games = @games.where('id NOT IN (?)', taken_games) if taken_games.count > 0

		# bounties. filter for only destiny
		#@is_bounties = params[:n] == 'b'
		#if @is_bounties
		#	@my_games = @my_games.select do |g|
		#		g.title == 'Destiny'
		#	end
		#	@games = @games.select do |g|
		#		g.title == 'Destiny'
		#	end
		#end
	end

	def show
		render layout: 'about'
		# p game
	end

	def lfg
		render layout: 'about'
		render :show
	end
end
