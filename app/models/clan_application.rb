class ClanApplication < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :clan, -> { with_deleted }
  belongs_to :user
  has_many :answers
  has_one :reviewer,  class_name: "User", primary_key: :reviewer_id, foreign_key: :id
  has_many :messages, :as => :notified_object

  validates :clan_id, :user_id, presence: { message: "Required" }

  accepts_nested_attributes_for :answers, :allow_destroy => true
  validates_associated :answers


  # Interesting reading
  # http://www.rubydoc.info/github/ging/mailboxer/Mailboxer/Notification
  def send_message
    subj = "'#{user.username}' Has Applied To '#{clan.name.upcase}'"
    message = self.messages.create(message_type: 'clan_applications', subject: subj)
    clan.host.receipts.create(message: message, message_type: message.message_type)
    clan.clan_members.preload(:user, :clan_rank).joins("left join clan_ranks on clan_ranks.id = clan_members.clan_rank_id").where('clan_members.user_id != ? AND clan_ranks.review_applications = ?', clan.host_id, true).each do |member|
      if member.clan_rank.review_applications?
        member.user.receipts.create(message: message, message_type: message.message_type)
      end
    end

  end

  def pending?
    status.nil?
  end

  def accepted?
    status == true
  end

  def rejected?
    status == false
  end

  def view_status
    pending? ? 'Pending' : accepted? ? 'Accepted' : rejected? ? 'Rejected' : 'Unknow'
  end

end
