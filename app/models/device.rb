class Device < ActiveRecord::Base
  belongs_to :user
  validates :device_token, presence: { message: "Required" }
  validates :device_type, presence: { message: "Required" }
end
