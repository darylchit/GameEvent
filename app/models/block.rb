class Block < ActiveRecord::Base
  belongs_to :user
  belongs_to :blocked_user, :class_name => 'User', :foreign_key => 'blocked_user_id'
  belongs_to :contract
end
