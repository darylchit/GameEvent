class Admin::SystemAvatarsController < InheritedResources::Base
	before_filter :authenticate_admin!
	respond_to :html

	def index
		@grid = initialize_grid(collection,
			order: 'name',
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
			params.permit(system_avatar: [:name])
    end
end

