class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :rated_user, class_name: 'User'

  #validates_inclusion_of :personality_rating, in: 1..5
  #validates_inclusion_of :approval_rating, in: 1..5
  #validates_inclusion_of :skill_rating, in: 1..5
  validates :user, presence: { message: "User is Required" }
  validates :rated_user, presence: { message: "Rated User is Required" }
  validates :rated_user_id, uniqueness: { scope: :user_id }
end
