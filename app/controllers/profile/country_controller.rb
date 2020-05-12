class Profile::CountryController < InheritedResources::Base

	defaults :resource_class => User

	before_filter :authenticate_user!
	respond_to :html

	def update
    @user = resource
    @user.do_country_validation = true
		update!{ root_url }
	end

	private
    def permitted_params
			params.permit( user: [ :country ] )
    end

	protected
    def resource
      current_user
    end
end
