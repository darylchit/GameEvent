class ClanNotice < Notice
  belongs_to :clan
  belongs_to :user

  validates_presence_of :clan_id, :message => "Clan is Required"
  validates_presence_of :user_id, :message => "User is Required"

  # Used for getting a user's clan notices for dashboard
  def self.get_user_notices user
    notices = []
    user.clans.each{ |c| notices << current(c.clan_notices) }
    notices.flatten.sort_by!{|n| n.updated_at}.reverse
  end
end
