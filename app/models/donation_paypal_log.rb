class DonationPaypalLog < ActiveRecord::Base
  belongs_to :donation
  belongs_to :clan_donation
end
