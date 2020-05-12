class Profile::AccountController < InheritedResources::Base
	defaults :resource_class => User
	before_filter :authenticate_user!
	respond_to :html

	def update
    @user = resource
    @user.do_country_validation = true

		update!{ edit_profile_account_path}
	end

	def create
		redirect_to edit_profile_account_path
	end

	def destroy
		redirect_to edit_profile_account_path
	end

	private
    def permitted_params
		if params[:user] and ( params[:user][:password].present? or params[:user][:password_confirmation].present? )
			params.permit(user: [:first_name, :last_name, :address_1, :address_2,
				:country, :city, :state, :zipcode, :password, :password_confirmation,
				:paypal_email, :date_of_birth, :public_age, :email
			])
		else
			params.permit(user: [:first_name, :last_name, :address_1, :address_2,
				:country, :city, :state, :zipcode, :paypal_email, :date_of_birth, :public_age, :email
			])
		end
    end

	protected
    def resource
      current_user
    end

end
