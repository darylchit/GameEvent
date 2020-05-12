class Admin::GamesController < InheritedResources::Base
	before_filter :authenticate_admin!
	respond_to :html

	def index
		@grid = initialize_grid(collection,
			order: 'title',
			order_direction: 'asc',
			per_page: 30,
			name: 'grid',
		)
		super
	end

	def update
		update!{edit_resource_path}
	end

	def create
		create!{edit_resource_path if @game.persisted?}
	end

	private
    def permitted_params
		params.permit(game: [:title, :affiliate_network_link, :active ,:release_date, :game_cover, :game_jumbo, :game_jumbo_mobile, :game_logo,
			:game_cover_cache, :game_jumbo_cache, :game_jumbo_mobile_cache, :game_logo_cache, 
			game_system_ids: []
		])
    end
end

