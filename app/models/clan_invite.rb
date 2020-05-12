class ClanInvite < ActiveRecord::Base
  before_create :init_invite
  belongs_to :user
  belongs_to :clan
  belongs_to :inviter, class_name: 'User'
  enum status: [:pending, :confirmed, :declined]

  validates_presence_of :user_id, :clan_id, :inviter_id, :message => "Required"
  validates :user, uniqueness: {scope: [:clan_id, :inviter_id]}

  def pending?
    self.status == "pending"
  end

  def is_invite?
    inviter != user
  end

  def is_request?
    inviter == user
  end

  def sent_request?

  end

  def approved?
    status == "confirmed"
  end

  def confirm approver
    if (is_request? && self.clan.is_host?(approver)) || is_invite?
      self.status = "confirmed"
      ClanMember.create(user: user, clan: clan)
    end
  end

  def deny approver
    if (is_request? && self.clan.is_host?(approver)) || is_invite?
      self.status = "declined"
      return true
    end
    false
  end

  # Interesting reading
  # http://www.rubydoc.info/github/ging/mailboxer/Mailboxer/Notification
  def send_message
    if self.is_request?
      #TODO clan invitation request
      # subj = "#{user.username} wants to join clan #{clan.name}"
      # body = "#{user.username} wants to join clan #{clan.name}"
      # # byebug
      # n = clan.host.notify(subj, body, self)
      # # byebug
      # # in future
      # # self.clan.host.notify_all(recip, subj, body, obj)
    else
      # body = "#{self.inviter.username} invites you to join clan #{self.clan.name}"
      # self.user.notify(subj, body, self)
      subj = "#{inviter.username} Has Invited You to Join #{self.clan.name}"
      message = inviter.messages.create(message_type: 'clan_invitations',subject: subj ,notified_object: clan)
      user.receipts.create(message: message, message_type: message.message_type)
    end
  end

  private

    def init_invite
      self.status = "pending"
    end


end
