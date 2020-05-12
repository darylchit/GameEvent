class Invite < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user
  belongs_to :event

  #acts_as_list scope: :event

  validates :user, :event, presence: { message: "Required" }
  validates :user, uniqueness: { scope: :event, message: "already invited" }

  enum status: [:pending, :confirmed, :declined, :waitlisted, :no_show, :clan_member]

  # not waitlisted
  scope :interested, -> () { where status: [ 0, 1, 3 ] } # :pending, :confirmed, :waitlisted
  scope :rateable, -> () { where status: [ 1, 4 ] } # :confirmed, :no_show
  scope :pending_or_confirmed_or_waitlisted, -> () { where status: [ Invite.statuses[:pending],
                                                                    Invite.statuses[:confirmed],
                                                                    Invite.statuses[:waitlisted]]}

 # folllwing code is old
  belongs_to :contract
  belongs_to :roster, class_name: "Roster", foreign_key: :contract_id
  # acts_as_list scope: :contract
  # after_save :schedule_upcoming_notification

  def claimable?
    # can this invite be confirmed!
    ( pending? or declined? )  and !roster.full?
  end

  def declinable?
    # can this invite be declined!
    !declined?
  end

  def waitlistable?
    roster.full? and !confirmed? and !waitlisted?
  end

  def send_join_notification!
    message = self.user.messages.find_or_create_by(message_type: :user_joins_roster, notified_object: self)
    invites = self.event.invites.confirmed.where('user_id != ?', user_id)
    invites.each do |invite|
      invite.user.receipts.find_or_create_by(message: message, message_type: message.message_type)
    end
  end

  def send_leave_notification!
    message = self.user.messages.find_or_create_by(message_type: :user_leaves_roster, notified_object: self)
    invites = self.event.invites.confirmed.where('user_id != ?', user_id)
    invites.each do |invite|
      invite.user.receipts.find_or_create_by(message: message, message_type: message.message_type)
    end
  end

  def declined!
    move_to_bottom
    super
    subj = "#{user.username} has declined their invitation"
    body = "%s. [roster id=\"%d\" invited_user_id=\"%d\"]" % [ subj, roster.id, user.id ]
    roster.send_message body, subj
  end

  def waitlisted!
    move_to_bottom
    super
    subj = "#{user.username} has been placed on the waitlist"
    body = "%s. [roster id=\"%d\" invited_user_id=\"%d\"]" % [ subj, roster.id, user.id ]
    roster.send_message body, subj
  end

  def confirmed!
    super
    # send out messages
    subj = "#{user.username} has confirmed their invite"
    body = "%s. [roster id=\"%d\" invited_user_id=\"%d\"]" % [ subj, roster.id, user.id ]
    roster.send_message body, subj
  end

  def schedule_upcoming_notification
    roster.schedule_upcoming_notification
  end

end
