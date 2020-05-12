class Api::V1::SubscriptionsController < Api::BaseController
  respond_to :json
  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User

  # Create a subscription from an appstore purchase
  #
  # POST /api/v1/subscriptions
  # @param [String] itunes_receipt Base64'd string of iTunes Receipt
  #
  # @return `201` if successful
  #
    def create
      @itunes_receipt = params[:subscription][:itunes_receipt] rescue nil

      Itunes.shared_secret = ENV["itunes_secret"]
      if Rails.env.development?
        verify = Itunes::Receipt.verify! @itunes_receipt, :allow_sandbox_receipt
      else
        verify = Itunes::Receipt.verify! @itunes_receipt, :allow_sandbox_receipt
      end

      @latest = verify.latest.last
      @product_id = @latest.product_id
      @purchase_date = @latest.purchase_date
      @transaction_id = @latest.transaction_id

      @subscription_plan = SubscriptionPlan.where(:product_id => @product_id).first

      @subscription = Subscription.where(:token => "IOS-"+@transaction_id).first

      if @subscription
        @subscription.ends_on = @subscription_plan.monthly? ? @purchase_date + 1.month : @purchase_date + 1.year
      else
        @subscription = current_user.build_active_subscription(
          subscription_plan: @subscription_plan,
          token: "IOS-"+@transaction_id,
          ends_on: @subscription_plan.monthly? ? @purchase_date + 1.month : @purchase_date + 1.year,
          platform: :ios
        )
      end

      if @subscription.save
        render json: {
          success: true
        }
      else
        render json: {
          success: false
        }
      end

    rescue Exception => e
      logger.warn e.message
      render json: {
        success: false
      }
    end
end
