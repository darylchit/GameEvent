class Clan < ActiveRecord::Base
  acts_as_paranoid

  extend FriendlyId
  friendly_id :name, use: :slugged

  CLAN_GAME_LIMIT = 4
  has_one :host,  class_name: "User", primary_key: :host_id, foreign_key: :id
  has_many :clan_members, dependent: :destroy
  has_many :clan_notices
	has_many :users, through: :clan_members
	has_many :clan_messages, dependent: :destroy
  has_one  :default_rank, class_name: "ClanRank", primary_key: :default_rank_id, foreign_key: :id
  has_many :clan_ranks, dependent: :destroy
  has_many :rosters, class_name: 'Roster', foreign_key: :clan_id
  has_many :contract_game_game_system_joins, through: :rosters
  has_many :games, through: :contract_game_game_system_joins
  has_many :game_systems, through: :contract_game_game_system_joins
  has_many :links
  has_many :video_urls, as: :video_urlable
  has_many :clan_donations
  has_many :questions
  has_many :clan_applications
  has_many :answers
  has_many :events
  has_many :recurring_events

  belongs_to :clan_avatar
  has_and_belongs_to_many :games
  has_and_belongs_to_many :game_systems

  # validates_each :clan_games do |clan, attr, value|
  #   user.errors.add attr, "too much things for user" if clan.clan_games.size > Clan::CLAN_GAME_LIMIT
  # end

  accepts_nested_attributes_for :links, :allow_destroy => true, reject_if: proc { |attributes| attributes['url'].blank? }
  validates_associated :links
  accepts_nested_attributes_for :video_urls, :allow_destroy => true, reject_if: proc { |attributes| attributes['url'].blank? }
  validates_associated :video_urls, :message=> "Video URL is Required"
  accepts_nested_attributes_for :questions, :allow_destroy => true
  validates_associated :questions #, :message=>"Question: Can't be blank"
  accepts_nested_attributes_for :clan_ranks
  validates_associated :clan_ranks

  validates :name, presence: { message: "Name is Required" }
  validates_length_of :name, :maximum => 35
  validates :name, uniqueness: { :case_sensitive => false, message: "This Clan Name Is Already Taken" }
  validates :name, :exclusion => { in: %w[confirmation] }
  validates :motto, presence: { message: "Motto is Required" }
  validates_length_of :motto, :maximum => 40, message: "Motto Cannot Be More Than 40 Characters"
  validates :game_type, presence: { message: "Game Type is Required" }
  validates :play_style, presence: { message: "Play Style is Required" }
  validates :most_active, presence: { message: "Most Active is Required" }
  validates :most_active_days, presence: { message: "Most Active Days is Required" }
  validates :game_ids, presence: { message: "Active Game is Required" }
  validates :bio, presence:  { message: "Bio is Required" }
  # validates :ground_rules, presence: true
  # validates :requirements, presence: true
  validates :timezone, presence: { message: "Time Zone is Required" }
  validates :languages, presence: { message: "Language is Required" }
  validates :minimum_age, presence: { message: "Minimum Age is Required" }
  # validates :paypal_email, presence: { message: "Paypal Email: Can't be blank" }
  validates :country, presence:  { message: "Country is Required" }
  validates :annual_dues_amount,  numericality: { greater_than_or_equal_to: 0,  only_integer: true, message: "Annual Dues Amount is Required" }
  validates :access_code, length: {is: 6, message: "Clan Access Code Must Be Six Digits" }, allow_blank: true, if: proc { |attributes| attributes['status'] == 'restricted' }
  validates :access_code, presence: {message: "Clan Access Code Required If Clan Status Is Restricted"}, if: proc { |attributes| attributes['status'] == 'restricted' }

  # custome validation
  validate :games_up_to_four, :clan_ranks_only_three, :validate_questions, :validate_game_systems
  validate :validate_popular_links
  validate :validate_annual_dues_amount#, :presence => true, :if => "annual_dues_amount.blank?"
  validate :validate_minimum_image_size
  after_create :init_clan
	mount_uploader :cover, ClanCoverUploader
	mount_uploader :jumbo, ClanJumboUploader
	mount_uploader :mobile_jumbo, ClanMobileJumboUploader

  before_save :save_annual_dues_amount

  include Searchable
  extend  Searchable

  POPULAR_TIMES = ["All Times", "Morning", "Daytime", "Afternoon", "Night"]

  POPULAR_DAYS = ["All Days", "Weekdays", "Weekends"]

  GAME_TYPE =  ["All Styles", "Player vs. Player", "Player vs. Enemy"]
  PLAY_STYLE = ["All Styles", "Casual", "Competitive"]

  AGE_RANGES = {
                "13 to 18": "13 - 18",
                "19 to 26": "19 - 26",
                "27 to 35": "27 - 35",
                "36 to 55": "36 - 55",
                "56+": "56 - 99"
               }

  MEMBER_RANGES = {"0 to 19 Members": "0 - 19",
                "20 to 100 Members": "20 - 100",
                "101 to 500 Members": "101 - 500",
                "Over 500 Members": "Over 500"
               }

  INACTIVE_USER_RANGES = {"Never": " ",
                "30 Days": "30",
                "60 Days": "60",
                "90 Days": "90",
                "120 Days": "120",
                "150 Days": "150",
                "180 Days": "180",
                "210 Days": "210",
                "240 Days": "240",
                "270 Days": "270",
                "300 Days": "300",
                "330 Days": "330",
                "360 Days": "360"
               }
  STATUSES = {
              'Open - Anyone Can Join':       'open',
              'Closed - Nobody Can Join':     'closed',
              'Recruiting - Application Required': 'recruiting',
              'Restricted - Access Code Required': 'restricted'
  }

  ANNUAL_DUES = {
   'Optional' => 1,
   'Yes' => 2,
   'No' =>  0
  }
  ALPHABETICAL = [["Most Posted Events", 'most_posted_events'],
                  ["Member Size", 'member_size'],
                  ["Alphabetical A - Z", 'name_asc'],
                  ["Alphabetical Z - A", 'name_desc']
                 ]
  PROFANITY = ["Yes","No"]
  MY_CLANS = [["Yes", "true"], ["No", "false"]]

  ACTIVITY_LEVEL_FILTER = [['Select a Level', ''],
                           ['Very Active', '5'],
                           ['Moderately Active', '4'],
                           ['Somewhat Active', '2,3' ],
                           ['Not Active', '1' ]]

  MINIMUMAGE = Array(13..35).unshift('None')
  # def join user, invite=nil
  #   if private? and not invite
  #      return nil
  #   else
  #     ClanMember.create(clan_id: id, user: user)
  #   end
  # end


  # Please do not chnage this is overriden method remove space from start and end of the string before savingto database
  def name=(name)
    write_attribute(:name, name.try(:strip))
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  def validate_minimum_image_size
    if !jumbo_cache.nil? && (jumbo.width < 1900 || jumbo.height < 670)
      errors.add(:jumbo , "Desktop image is too small and must be at least 1900px X 670px" )
    end

    if !mobile_jumbo_cache.nil? && (mobile_jumbo.width < 600 || mobile_jumbo.height < 285)
      errors.add(:mobile_jumbo , "Mobile image is too small and must be at least 600px X 285px" )
    end

    if !cover_cache.nil? && (cover.width < 400 || cover.height < 400)
      errors.add(:cover , "Clan Avatar image is too small and must be at least 400px X 400px" )
    end
  end

  def recruiting?
    status == 'recruiting'
  end

  def closed?
    status == 'closed'
  end

  def open?
    status == 'open'
  end

  def restricted?
    status == 'restricted'
  end

  def self.define_order(order, resource)
    case (order)
      when "Most Posted Events"
        resource
      when "Member Size"
        resource
      when "Alphabetical A - Z"
        resource.order(name: :asc)
      when "Alphabetical Z - A"
        resource.order(name: :desc)
      else
        resource
    end
  end

  def self.search_by_name(name)
    where("LOWER(name) ILIKE ?", "%#{name.downcase}%").take
  end


  def top_3_game_game_system_joins
    #there has to be a better way to do this...
    contract_game_game_system_joins
    .group('game_game_system_join_id')
    .select('game_game_system_join_id,  count(game_game_system_join_id) as game_count')
    .order('game_count desc').limit(3)

  end

  def top_3_systems
    top_3_game_game_system_joins.map(&:game_system).uniq

  end

   def top_3_games
     Game.joins('LEFT JOIN game_game_system_joins ON games.id = game_game_system_joins.game_id LEFT JOIN events ON game_game_system_joins.id = events.game_game_system_join_id')
         .where('events.id in (?)', events.ids)
         .group(:id)
         .order('count(events.id) DESC')
         .limit(3)
   end

   def most_popular_game
    top_3_game_game_system_joins.first.game
   end


  def member user
    cm = clan_members.find_by(user_id: user.id)
    return cm ? cm : false
  end

  def member_or_removed_member? user
    cm = clan_members.with_deleted.find_by(user_id: user.id)
    return cm ? cm : false
  end

  def member_removed? user
    cm = clan_members.deleted.find_by(user_id: user.id)
    return cm ? cm : false
  end

  def active_member? user
    cm = clan_members.find_by(user_id: user.id)
    return cm ? cm : false
  end

  def application_reveiewer? user
    member = active_member? user
    if is_host? user
      true
    elsif member
      member.try(:clan_rank).try(:review_applications?)
    else
      false
    end
  end

  def allow_reapply_application?
    re_apply
  end


  def is_host? user
    host_id == user.id
  end

  def can_perform? user, action
    cm = member user
    cm ? cm.can_perform?(action) : false
  end

  # Currently sorts by most recently active games for clan.
  def self.get_clan_titles_for_user user
    game_joins = []
    game_ids = []
    clans = user.clan_members.ids

    # If the user doesn't have any clans show them the most recent contract games
    # that have a clan id associated with it.
    log = clans.empty? ? lambda { |c| c.clan_id != nil } : lambda { |c| clans.include?(c.clan_id) }
    game_joins << Contract.order('start_date_time desc').select{ |c| log.call(c) }

    game_joins[0].each{ |g| game_ids << g.game_game_system_joins.first.game_id }
    return game_ids.uniq.map{ |g| Game.find(g) }
  end

  # return all contracts for a clan newest first
  def get_contracts
    Contract.where(clan_id: id).order('start_date_time desc')
  end

  def get_contracts_upcoming
    Contract.where(clan_id: id).where('start_date_time > ?', Time.now).order('start_date_time desc')
  end

  def get_contracts_previous
    Contract.where(clan_id: id).where('start_date_time < ?', Time.now).order('start_date_time desc')
  end

  def get_game_ids
    contracts = get_contracts
    return contracts.map{ |c| c.game_game_system_joins.first.game_id }.uniq
  end

  def get_games
    games = get_game_ids
    return games.map{ |t| Game.find(t) }
  end

  def get_member_ids
    return clan_members.pluck(:user_id)
  end

  def get_members
    members = get_member_ids
    return members.map{ |m| User.find(m) }
  end

  def get_host
    host_id.nil? ? nil : User.find(host_id)
  end

  def add_member member_params
    clan_member = ClanMember.with_deleted.find_by(member_params)
    if clan_member.present?
      clan_member.restore
    else
      ClanMember.create(member_params)
    end
  end

  def add_rank title, permissions, level
    ClanRank.create(clan_id: self.id, title: title, permissions: permissions.map{|p| p.to_sym}, level: level)
  end

  def remove_rank id
    rank = ClanRank.find(id)
    rid = rank.id
    return false if clan_ranks.count < 2 || rank.clan != self || rank == default_rank
    begin
      return !!ClanRank.find(id).destroy
    rescue
      return false
    end
  end

  def init_ranks
    member_rank = add_rank "Member", [:post_to_forum, :post_to_events], 1
    add_rank "Lieutenant", [:invite_users, :accept_users], 2
    set_default_rank member_rank
  end

  def set_default_rank rank
    return false if rank.clan != self
    self.update(default_rank_id: rank.id)
  end

  def calcuate_activity_level_rating
    activity_level = nil
    events_count = self.events.where(start_at: ( DateTime.now - 15.days..DateTime.now + 15.days)).count
    members_count = self.clan_members.count
    if members_count < 10 && events_count <= 2
      activity_level = 0
    else
      events_count = events_count + 1
      activity_level =  events_count >= 5 ? 5 : events_count
    end
    activity_level
  end

  def calculate_average_age

      if clan_members.present?
        clan_members = self.clan_members
        if clan_members.count < 100
        pool_of_members = clan_members
        else
        pool_of_members = clan_members.sample(100)
      end

        ages = pool_of_members.map{|u| u.user.age}
      end
      (ages.reduce(:+).to_f / ages.size).round if ages.present?
  end

  def cover_url_with_domain
    if cover.present?
      cover.url(:cover)
    elsif clan_avatar.present?
      clan_avatar.avatar_path
    else
      'clan_cover.jpg'
    end
  end

  def mobile_jumbo_url_with_domain
    if mobile_jumbo.present?
      mobile_jumbo.url(:mobile_jumbo)
    elsif clan_avatar.present?
      clan_avatar.mobile_jumbo_path
    else
      'clan_mobile_jumbo.jpg'
    end
  end

  def self.welcome_mail id
    clan = Clan.find_by_id id
    if clan.present? && clan.host.present?
      ApplicationMailer.send_clan_welcome_email(clan.host).deliver_now
    end
  end

  private
    def init_clan
      ClanMember.create(clan: self, user_id: host_id)
      self.clan_avatar_id = rand(1..ClanAvatar.count)
      self.save
      #init_ranks
      clan_messages.create(message: 'Welcome', user: host)
      Clan.delay(priority: 8).welcome_mail id
      message = host.messages.create(message_type: 'clan_messages', subject: 'clan_chat', body: 'clan_chat', notified_object: self)
      clan_members.each do |member|
        member.user.receipts.create(message: message, message_type: message.message_type)
      end
    end

    def save_annual_dues_amount
      if annual_dues == 0
        self.annual_dues_amount = 0
      end
    end


    def games_up_to_four
      errors.add(:game_ids, "Active Games: Please Select Up to Four Games") if games.size > 4
    end

    def clan_ranks_only_three
      errors.add(:clan_ranks, "Require three Rank") if clan_ranks.size != 3
    end

    def validate_questions
      if status == 'recruiting' && questions.size == 0
        errors.add(:questions, "Application Questions Required If Clan Status Is Recruiting")
      end
    end

    def validate_annual_dues_amount
      if self.annual_dues == 2 && self.annual_dues_amount == nil
        errors.add(:annual_dues_amount, "Annual Dues Amount is Required.")
      end
    end

    def validate_game_systems
      errors.add(:game_system_ids, "Game Systems is Required.") if game_systems.size == 0
    end

    def validate_popular_links
      if youtube.present? && youtube.strip.include?('youtube.com')
      elsif youtube.present?
        errors.add(:youtube, "Youtube: Enter Valid URL")
      end

      if facebook.present? && facebook.strip.include?('facebook.com')
      elsif facebook.present?
        errors.add(:facebook, "Facebook: Enter Valid URL")
      end

      if google.present? && google.strip.include?('google.com')
      elsif google.present?
        errors.add(:google, "Google: Enter Valid URL")
      end

      if discord_invitation.present? && (discord_invitation.strip.include?('discord.gg') || discord_invitation.strip.include?('discordapp.com'))
      elsif discord_invitation.present?
        errors.add(:discord_invitation, "Discord Invitation: Enter Valid URL")
      end

      if discord.present? && discord.strip.include?('discordapp.com')
      elsif discord.present?
        errors.add(:discord, "Discord Server: Enter Valid URL")
      end

      if scuf.present? && scuf.strip.include?('scufgaming.com/')
      elsif scuf.present?
        errors.add(:scuf, "Scuf: Enter Valid URL")
      end

      if mixer_url.present? && mixer_url.strip.include?('mixer.com/')
      elsif mixer_url.present?
        errors.add(:mixer_url, "Mixer: Enter Valid URL")
      end

      if curse.present? && curse.strip.include?('app.twitch.tv/servers/')
      elsif curse.present?
        errors.add(:curse, "Curse Server: Enter Valid URL")
      end

      if slack.present? && slack.strip.include?('slack.com')
      elsif slack.present?
        errors.add(:slack, "Slack: Enter Valid URL")
      end

      if reddit.present? && reddit.strip.include?('reddit.com')
      elsif reddit.present?
        errors.add(:reddit, "Reddit: Enter Valid URL")
      end

      if steam.present? && steam.strip.include?('steamcommunity.com')
      elsif steam.present?
        errors.add(:steam, "Steam Community: Enter Valid URL")
      end

      if legend.present? && legend.strip.include?('leagueoflegends.com')
      elsif legend.present?
        errors.add(:legend, "League of Legends: Enter Valid URL")
      end

      if battle.present? && battle.strip.include?('battle.net')
      elsif battle.present?
        errors.add(:battle, "Battle.net: Enter Valid URL")
      end

      if wargaming.present? && wargaming.strip.include?('wargaming.net')
      elsif wargaming.present?
        errors.add(:wargaming, "Wargaming.net: Enter Valid URL")
      end

      if battlelog.present? && battlelog.strip.include?('battlefield.com')
      elsif battlelog.present?
        errors.add(:battlelog, "Battlefield.com: Enter Valid URL")
      end

      if patreon.present? && patreon.strip.include?('patreon.com')
      elsif patreon.present?
        errors.add(:patreon, "Patreon: Enter Valid URL")
      end

      if mlg.present? && mlg.strip.include?('majorleaguegaming.com')
      elsif mlg.present?
        errors.add(:mlg, "Major League Gaming: Enter Valid URL")
      end

      if bungie.present? && bungie.strip.include?('bungie.net')
      elsif bungie.present?
        errors.add(:bungie, "Bungie.net: Enter Valid URL")
      end
    end
end
