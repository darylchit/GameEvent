class EventMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  default_scope {order(created_at: :desc)}
  validates_presence_of :message, :message => "Message is Required"
end
