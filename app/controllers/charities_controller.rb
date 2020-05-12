class CharitiesController < InheritedResources::Base

	def index
    	@charity = Charity.all
    	@users = User.all
	end

	def show
		@users = User.all
	end

end
