class Profile::SubscriptionController < InheritedResources::Base

	before_filter :authenticate_user!

  expose :active_subscription, :build_active_subsciption

  expose :pro_plan do
		SubscriptionPlan.active.find_by_name(:Pro)
  end

	expose :elite_plan do
		SubscriptionPlan.active.find_by_name(:Elite)
	end

	expose :active_subscription_plans do
		SubscriptionPlan.active
	end

	expose :subscription_plans do
		plans =  SubscriptionPlan.active.map{|sp| ["#{sp.name}: $#{sp.price} per Year", sp.id]}
		plans.unshift ["Basic: Free", :basic]
	end


  def index
    #@subscription_plans = SubscriptionPlan.order(price: :asc).all
    respond_to do |format|
      format.html {redirect_to player_path(current_user)}
      format.js
    end
  end

	protected

  def build_active_subsciption
    current_user.active_subscription
  end

end
