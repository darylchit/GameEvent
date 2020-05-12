class Admin::UsersController < InheritedResources::Base
	before_filter :authenticate_admin!
	respond_to :html

	expose :active_subscription_plan, :build_active_subscription_plan
	expose :resource_setting, :build_user_setting

	def index
		@users = initialize_grid(collection,
			order: 'created_at',
			order_direction: 'desc',
			per_page: 30,
			name: 'users',
			enable_export_to_csv: true,
			csv_file_name: 'users',
			conditions: ['deleted_account= ?', false]
		)
		#should user management list deleted accounts?
		export_grid_if_requested
		# super
	end

  def confirm
    resource.confirm!
    flash[:notice] = "#{resource.username} successfully confirmed"
    redirect_to admin_users_path
  end

	def profile

	end

	def account

	end

	def update
		if params[:user][:email]
			resource.assign_attributes(permitted_params[:user])
			resource.skip_reconfirmation!
			if resource.save
				flash[:notice] = "#{resource.username}'s account has been updated"
				redirect_to admin_user_path
			else
				render 'account'
			end
		else
			update!{edit_resource_path}
		end
	end

	def destroy
		cur_username = resource.username
		resource.delete_account
		resource.skip_reconfirmation!
		resource.save!

		flash[:notice] = "#{cur_username}'s account has been deleted"
		redirect_to admin_users_path
	end

  def become
		sign_in(:user, User.find(params[:id]), { :bypass => true })
		if params[:prev_action]
			redirect_to params[:prev_action]
		else
    	redirect_to profile_path
		end
	end

	def stop_become
		sign_out current_user
		flash[:notice] = "Signed back in as admin"
		redirect_to root_path
	end

	def lifetime
		resource = User.find params[:id]
		if !resource.active_subscription.present?
			subscription_plan = SubscriptionPlan.find params[:subscription_plan_id]
			subscription = resource.build_active_subscription(
					subscription_plan: subscription_plan,
					ends_on: 1000.year.from_now,
					profile_id: DateTime.now.to_s[-8],
					token: DateTime.now.to_s[-8],
					subscription_type: Subscription.subscription_types[:lifetime]
			)
			subscription.save
		elsif resource.active_subscription.present? && resource.active_subscription.promotional?
			subscription_plan = SubscriptionPlan.find params[:subscription_plan_id]
			subscription = resource.active_subscription
			subscription.subscription_plan = subscription_plan
			subscription.subscription_type= Subscription.subscription_types[:lifetime]
			subscription.save
		end
		redirect_to admin_user_path(resource)
	end

	#custome_paypal
	def subscription
		subscription= Subscription.new(custome_subscription_params)
		if resource.active_subscription.present?
			flash[:notice] = 'Already has subscription'
			redirect_to admin_user_path(resource)
		elsif subscription.present? && subscription.ends_on.present? && subscription.subscription_plan.present?
			subscription.user = resource
			subscription.profile_id = DateTime.now.to_s[-8]
			subscription.token = DateTime.now.to_s[-8],
			subscription.subscription_type = Subscription.subscription_types[:paypal_paid]
			subscription.state = Subscription.states[:active]

			if subscription.save
				flash[:notice] = 'Subscription Created'
			else
				flash[:notice] = 'Something is wrong'
			end
			redirect_to admin_user_path(resource)
		else
			flash[:notice] = 'please enter propepdata for subscription'
			redirect_to admin_user_path(resource)
		end
	end

	def remove_lifetime
		if resource.active_subscription.present? && (resource.active_subscription.lifetime? || resource.active_subscription.promotional? || resource.active_subscription.paypal_paid?)
			active_subscription = resource.active_subscription
			active_subscription.ends_on = Time.now
			active_subscription.state = Subscription.states[:completed]
			active_subscription.save
		end
		redirect_to admin_user_path(resource)
	end

	def user_setting
    if resource_setting.present?
			resource_setting.update(user_setting_params)
			redirect_to admin_user_path(resource)
		else
			redirect_to root_path
		end
	end

  private

	def build_user_setting
    resource = User.find params[:id]
	  user_setting = UserSetting.find params[:user_setting_id]
	  if user_setting.id == resource.user_setting.id
			user_setting
	  else
		  nil
	  end
	end

	def user_setting_params
		params.require(:user_setting).permit(:admin_personality, :admin_skill, :admin_respect, :admin_cancellation_count, :admin_event_completed)
	end

	def permitted_params
		if params[:user][:email].present?
			params.permit(user: [:country, :paypal_email, :date_of_birth, :email, :username
		])
		else
			params.permit(user: [:trial_expiration])

		end
	end

	def custome_subscription_params
		params.require(:subscription).permit(:ends_on, :subscription_plan_id)
	end

  def build_active_subscription_plan
	 SubscriptionPlan.active
  end
end
