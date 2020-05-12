class StripeSubscriptionsController < ApplicationController

  protect_from_forgery with: :null_session, except: [:create]
  before_filter :authenticate_user!

  expose :subscription_plans, :build_subscription_plans
  #for destroy
  expose :subscription
  #for update
  expose :subscription_plan

  def new
    respond_to do |format|
      format.js
      format.html { redirect_to root_path }
    end
  end

  def create
   stripe_error = false
   plan = SubscriptionPlan.find(params[:plan_id])
    user_setting = current_user.user_setting
    if user_setting.stripe_customer.present?
      customer = Stripe::Customer.retrieve(user_setting.stripe_customer)
    else
      customer = Stripe::Customer.create(
        :email => current_user.email,
        :source  => params[:stripeToken]
      )
    end

    stripe_subscription = customer.subscriptions.create(:plan => plan.stripe_plan_id)

    if customer.present? && stripe_subscription.present?
      active_subscription = current_user.active_subscription
      if active_subscription.present?
        active_subscription.update_attributes(ends_on: Time.now, state: Subscription.states[:completed])
      end
      subscription = current_user.subscriptions.new(
        state: Subscription.states[:active],
          subscription_plan: plan,
          ends_on: plan.monthly? ? 1.month.from_now : 1.year.from_now,
          profile_id: customer.id,
          token: stripe_subscription.id
      )
      subscription.save

      if subscription.persisted?
        user_setting.update_attributes(stripe_customer: customer.id)
      else
        stripe_error = true
      end
    else
      stripe_error = false
    end

    if stripe_error
      flash[:notice] = "We could not complete your transaction.  Please review your details and try again. Contact Us if the problem persists".upcase
    else
      flash[:notice] = "Transaction complete.  Thank you for subscribing.".upcase
    end
    redirect_to edit_profile_path
  end

  def update
    active_subscription =  current_user.active_subscription
    if active_subscription.nil? && subscription_plan.present?
      customer = Stripe::Customer.retrieve(current_user.user_setting.stripe_customer)
      stripe_subscription =  customer.subscriptions.data.first
      item_id = stripe_subscription.items.data[0].id
      items = [{ id: item_id,  plan:  subscription_plan.stripe_plan_id}]
      stripe_subscription.items = items
      stripe_subscription.save
      new_subscription = current_user.subscriptions.new(
          state: Subscription.states[:active],
          subscription_plan: subscription_plan,
          ends_on: (1.year.from_now),
          profile_id: customer.id,
          token: stripe_subscription.id
      )
      if new_subscription.save
        flash[:notice] = 'Transaction complete.  Your subscription has been updated.  The unused portion of your Pro subscription has been applied towards your new Elite subscription'
      end

    elsif active_subscription.present? && params[:id] == 'basic'
      p "DownGRADE==============================="
      if active_subscription.update_attributes(next_plan: :basic)
        flash[:notice] = 'Transaction complete. This change will take effect on your renewal date.'
      end
    elsif active_subscription.present?  && active_subscription.subscription_plan_id != subscription_plan.id
      if active_subscription.pro? && active_subscription.paid? && subscription_plan.elite?
        p "UPGRADE================================="

        active_stripe_subscription = Stripe::Subscription.retrieve(active_subscription.token)
        #start Basic
        item_id = active_stripe_subscription.items.data[0].id
        items = [{ id: item_id,  plan:  'basic'}]
        active_stripe_subscription.items = items
        active_stripe_subscription = active_stripe_subscription.save
        #start Elite
        item_id = active_stripe_subscription.items.data[0].id
        items = [{ id: item_id,  plan:  subscription_plan.stripe_plan_id}]
        active_stripe_subscription.items = items
        active_stripe_subscription.save

        #database changes
        active_subscription.update_attributes(ends_on: Time.now, state: Subscription.states[:completed])
        new_subscription = current_user.subscriptions.new(
            state: Subscription.states[:active],
            subscription_plan: subscription_plan,
            ends_on: (1.year.from_now),
            profile_id: active_stripe_subscription.customer,
            token: active_stripe_subscription.id
        )
        if new_subscription.save
          flash[:notice] = 'Transaction complete.  Your subscription has been updated.  The unused portion of your Pro subscription has been applied towards your new Elite subscription.'
        end

      elsif active_subscription.elite? && subscription_plan.pro?
        p "DownGRADE==============================="
        if active_subscription.update_attributes(next_plan: subscription_plan.stripe_plan_id)
          flash[:notice] = 'Transaction complete. This change will take effect on your renewal date.'
        end
        # stripe_subscription = Stripe::Subscription.retrieve(active_subscription.token)
        # item_id = stripe_subscription.items.data[0].id
        # items = [{ id: item_id,  plan:  subscription_plan.stripe_plan_id}]
        # stripe_subscription.items = items
        # stripe_subscription.save
        # end_date = active_subscription.ends_on
        # active_subscription
        # active_subscription.update_attributes(ends_on: Time.now, state: Subscription.states[:completed])
        #
        # new_subscription = current_user.subscriptions.new(
        #     state: Subscription.states[:active],
        #     subscription_plan: subscription_plan,
        #     ends_on: end_date,
        #     profile_id: active_subscription.profile_id,
        #     token: stripe_subscription.id
        # )
        # new_subscription.save
      else
        p 'No Changes'
      end

    end

    respond_to do |format|
      format.html {redirect_to edit_profile_path}
      format.js {}
    end
  end

  def destroy
    if subscription.update_attributes(next_plan: :basic)
      flash[:notice] = "Subscribtion Updated"
    else
      flash[:notice] = "We could not complete your transaction.  Please review your details and try again. Contact Us if the problem persists".upcase
    end
    redirect_to edit_profile_path
  end

  private

  def build_subscription_plans
    SubscriptionPlan.active
  end

end
