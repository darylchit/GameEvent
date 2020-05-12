class Message < ActiveRecord::Base

  has_many :receipts
  has_many :replies
  belongs_to :sender, polymorphic: true
  belongs_to :notified_object, -> { with_deleted }, polymorphic: true
  delegate :clan_messages, to: :notified_object
  scope :clan_event_invitations, -> { where(notified_object_type: "Event") }




end
