class SubscriptionPlan < ActiveRecord::Base
  enum period: [ :monthly, :yearly ]
  enum active: [ :inactive, :active]

  validates :name, :price, :period, :recurring, presence: { message: "Required" }

  def pro?
    name == 'Pro'
  end

  def elite?
    name == 'Elite'
  end
  
end
