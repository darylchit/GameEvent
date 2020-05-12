


class AuthorizeSubscriptionsController < ApplicationController


  include Authorize

  before_filter :authenticate_user!
  expose :subscription_plans, :build_subscription_plans
  expose :ex_months, :build_ex_months
  expose :ex_years, :build_ex_years
  expose :subscription


  def new
    respond_to do |format|
      format.js
      format.html { redirect_to root_path }
    end
  end

  def create
    subscription_plan = SubscriptionPlan.find(params[:subscription][:subscription_plan_id])
    @subscription = create_subscription(current_user, subscription_plan , params[:subscription])
  end


  private

  def build_subscription_hash

  end

  def build_subscription_plans
    SubscriptionPlan.active
  end

  def build_ex_months
    Date::MONTHNAMES
    months = []
    Date::MONTHNAMES.each_with_index do |t, index|
      i = index < 10 ? "0#{index}" : index
      months << [t, i == 0 ? '' : i]
    end
    months
  end

  def build_ex_years
    years = []
    temp = (((Time.now.strftime('%Y').to_i)..(Time.now.strftime('%Y')).to_i+10).to_a.unshift '')
    temp.each_with_index do |y, index|
      years << [y, y.to_s[2..3]]
    end
    years
  end

end
