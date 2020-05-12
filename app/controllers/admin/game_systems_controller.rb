class Admin::GameSystemsController < InheritedResources::Base
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
		create!{edit_resource_path if @game_system.persisted?}
	end

	private
    def permitted_params
		params.permit(game_system: [:title, :abbreviation, :display_rank])
    end
end

