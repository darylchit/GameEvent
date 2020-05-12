class Question < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :clan
  has_many :answers
  validates :name, presence:  { message: "Question: Can't be blank" }
  # validates :clan_id, presence: { message: "Clan is Required" }
end
