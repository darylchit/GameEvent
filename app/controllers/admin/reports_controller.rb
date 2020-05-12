class Admin::ReportsController < InheritedResources::Base
	before_filter :authenticate_admin!
	respond_to :html

  def index
    @reports = initialize_grid(collection,
      order: 'created_at',
      order_direction: 'desc',
      per_page: 30,
      name: 'grid',
    )
    super
  end

  def update
    resource.admin = current_admin
    resource.handled_at = DateTime.now
    super
  end

  private
    def permitted_params
      params.permit(report: [:admin_comment])
    end
end
