class Admin::RostersController < InheritedResources::Base
	before_filter :authenticate_admin!
	
	def index		
		#scoped to show rosters with no shows at the moment
			@grid = initialize_grid(Roster.includes(:invites).where(:invites=> {status: Invite.statuses[:no_show]}),
			order: 'start_date_time',
			order_direction: 'desc',
			per_page: 30,
			name: 'grid',
			)
	end
	

end