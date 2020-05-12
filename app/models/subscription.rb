class Subscription < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :subscription_plan

  delegate :name, to: :subscription_plan

  after_update :update_subscription_expiration!

  enum state: [ :pending, :active, :completed, :canceled, :suspended ]
  enum platform: [ :web, :ios, :android ]
  enum subscription_type: [ :paid, :promotional, :lifetime, :paypal_paid]

  attr_accessor :payer_id

  # Authorize.net
  attr_accessor :first_name, :last_name, :street_1, :street_2, :city, :sub_state, :zipcode, :card, :ex_month, :ex_year, :cvv, :terms

  delegate :name, to: :subscription_plan

  #
  # sync ends_on with users trial_expiration for active
  #
  def update_subscription_expiration!
    if active? and web? and user and ( !user.trial_expiration or ends_on > user.trial_expiration )
      user.update( trial_expiration: ends_on )
    end
  end

  def pro?
    name == 'Pro'
  end

  def elite?
    name == 'Elite'
  end

  def subscription_type_text
    if subscription_type.present? && paypal_paid?
      'PayPal Paid'
    else
      subscription_type.try(:titleize)
    end
  end
end
