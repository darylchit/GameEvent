class Admin::CharitiesController < InheritedResources::Base
	before_filter :authenticate_admin!
	respond_to :html

	def index
		@grid = initialize_grid(collection,
			order: 'charity_name',
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
		create!{edit_resource_path if @charity.persisted?}
	end

	private
    def permitted_params
		params.permit(charity: [:charity_name, :charity_about, :charity_url, :charity_logo, :charity_logo_cache])
    end
end
