class SubscriptionsController < ApplicationController
  before_filter :set_subscription_plan, only: [ :new, :create ]
	before_filter :authenticate_user!, :except =>[ :ipn_notification ]
	protect_from_forgery :except => [ :ipn_notifcation ]

  def promotional
    subscription =   current_user.active_subscription
    if subscription.present? && subscription.promotional? && !subscription.read?
    else
      redirect_to root_path
    end
  end

  def promotional_read
    subscription =   current_user.active_subscription
    if subscription.present? && subscription.promotional? && !subscription.read?
      subscription.read = true
      subscription.save
    end
    if current_user.source.present?
      redirect_to current_user.source
    else
      redirect_to root_path
    end
  end

  def new

    # check to see if we are returning from PAYPAL

    @token = params[:token]
    @payer_id = params[:PayerID]

    # First visit send to PayPal
    unless ( @token and @payer_id )

      ppr = PayPal::Recurring.new({
        :return_url   => new_subscription_plan_subscription_url(@subscription_plan),
        :cancel_url   => subscriptions_cancel_url,
        :ipn_url      => subscriptions_ipn_notification_url( host: Rails.application.config.ipn_host ),
        :description  => @subscription_plan.name,
        :amount       => @subscription_plan.price,
        :currency     => "USD"
      })

      response = ppr.checkout
      return redirect_to response.checkout_url if response.valid?
      logger.error "PayPal Error: [%s]" % response.to_json
      return redirect_to root_url, notice: t('.error_html')

    end

    # Back from PayPal confirm subscription

    @subscription = Subscription.new( payer_id: @payer_id, token: @token, subscription_plan: @subscription_plan )
  end

  def create
    @token = params[:subscription][:token] rescue nil
    @payer_id = params[:subscription][:payer_id] rescue nil

    @subscription = current_user.build_active_subscription(
      subscription_plan: @subscription_plan,
      token: @token,
      ends_on: @subscription_plan.monthly? ? 1.month.from_now : 1.year.from_now,
      payer_id: @payer_id
    )

    ActiveRecord::Base.transaction do

      if @subscription.save

        ppr = PayPal::Recurring.new({
          :amount      => @subscription_plan.price,
          :currency    => "USD",
          :description => @subscription_plan.name,
          :ipn_url     => subscriptions_ipn_notification_url( host: Rails.application.config.ipn_host ),
          :frequency   => 1,
          :token       => @token,
          :period      => @subscription_plan.period.to_sym,
          :reference   => @subscription.id,
          :payer_id    => @payer_id,
          :start_at    => Time.now,
          :failed      => 1,
          :outstanding => :next_billing
        })

        response = ppr.create_recurring_profile

        unless response.valid?
          logger.error "PayPal Error: [%s]" % response.to_json
          raise response.errors.first[:messages].join(',')
        end

        # add profile_id and activate subscription
        @subscription.update( profile_id: response.profile_id )
      end
    end

    #
    # Success
    #

    redirect_to profile_subscription_path

  rescue Exception => e
    logger.warn e.message
    flash.now[:error] = e.message
    render :new
  end

  def show
  end

  def destroy
    @subscription = current_user.active_subscription

    raise "Looks like your subscription has already been canceled" unless @subscription

    ppr = PayPal::Recurring.new( profile_id: @subscription.profile_id )

    response = ppr.cancel

    unless response.valid?
      logger.error "PayPal Error: [%s]" % response.to_json
      raise response.errors.first[:messages].join(',')
    end

    @subscription.canceled!
    redirect_to profile_subscription_path, notice: t('.notice_html')

  rescue Exception => e
    logger.warn e.message
    flash[:error] = e.message
    return redirect_to profile_subscription_path
  end

  def cancel
    redirect_to profile_subscription_path, notice: t('.notice_html')
  end

  def ipn_notification
  end

  private

  def set_subscription_plan
    @subscription_plan = SubscriptionPlan.find(params[:subscription_plan_id])
  end


end
