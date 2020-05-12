class Admin::EventsController < InheritedResources::Base
	before_filter :authenticate_admin!
	respond_to :html
  defaults :resource_class => Contract

  def index
    @events = initialize_grid(Contract,
      order: 'created_at',
      order_direction: 'desc',
      per_page: 30,
      name: 'events',
			enable_export_to_csv: true,
			csv_file_name: 'events',
    )
		export_grid_if_requested
  end
end
