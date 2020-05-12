class ClanDonation < ActiveRecord::Base
  MAX_CENTS = 200_00
  MIN_CENTS = 1_00

  has_many :logs, class_name: "DonationPaypalLog"

  include MoneyPenny

  dollarize :amount_cents

  belongs_to :user
  belongs_to :clan

  validate :reasonable_amount
  enum status: [ :pending, :complete, :error, :unknown ]


  def reasonable_amount
    return errors.add(:amount_dollars, "must be at least a $%.2f" % [ 0.01 * MIN_CENTS ]) unless amount_cents and amount_cents >= MIN_CENTS
    errors.add(:amount_dollars, "please limit to $%.2f" % [ 0.01 * MAX_CENTS ]) unless amount_cents <= MAX_CENTS
  end
end
