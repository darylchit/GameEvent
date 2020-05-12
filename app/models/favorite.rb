class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :favorited_user, :class_name => 'User', :foreign_key => 'favorited_user_id'
end
