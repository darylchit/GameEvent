class MercenariesController < ApplicationController
	before_filter :authenticate_user!
	def index
		params[:grid] = {} unless params[:grid].present?
		params[:grid][:page] = 1 # force to only the first page

		@grid = initialize_grid(User.all,
			order: 'username',
			order_direction: 'asc',
			per_page: 100,
			name: 'grid'
		)
	end
end
