class Api::V1::SubscriptionPlansController < Api::BaseController
  respond_to :json
  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User
  defaults :resource_class => SubscriptionPlan

  # Gets the list of product ids for subscription plans
  #
  # GET /api/v1/subscription_plans
  #
  # @return [Array<SubscriptionPlan>] `subscription_plans` unordered array of {SubscriptionPlan}s
  #
    def index
    respond_with collection, each_serializer: Api::V1::SubscriptionPlanSerializer
    end
end
