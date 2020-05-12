class RosterMessage < ActiveRecord::Base
    belongs_to :roster
    belongs_to :user

    default_scope {order(created_at: :asc)}
    validates_presence_of :message, :message => "Message is Required"


end
