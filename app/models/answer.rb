class Answer < ActiveRecord::Base
  belongs_to :clan
  belongs_to :user
  belongs_to :question,  -> { with_deleted }
  belongs_to :clan_application

  validates :clan_id, :user_id, :question_id, :answer, presence: { message: "Required" }
end
