class Event < ActiveRecord::Base

  include DiscordBot
  extend FriendlyId
  friendly_id :token, use: [:finders]

  acts_as_paranoid
  has_secure_token

  # enums
  enum event_type: [ :clan_event, :private_event, :public_event ]
  enum status: [:pending_open, :pending_full, :completed, :cancelled]

  # constonts

  DURATIONS = [["1 Hour", 60], ["2 Hours", 120], ["3 Hours", 180], ["4 Hours", 240], ["5 Hours", 300], ["6 Hours", 360], ["7 Hours", 420], ["8 Hours", 480], ["9 Hours", 540], ["10 Hours", 600], ["11 Hours", 660], ["12 Hours", 720]]
  WAITLIST = [['Yes', true],['No', false]]
  SPOTS_REMAINING_RANGES = {
                "1 or  More": "1",
                "2 or  More": "2",
                "3 or  More": "3",
                "4 or  More": "4",
                "5 or  More": "5"
               }
  AGE_RANGES = {
      "13 to 18": "13-18",
      "19 to 26": "19-26",
      "27 to 35": "27-35",
      "36 to 55": "36-55",
      "56+": "56-99"
  }

  STARTS_RANGES = [
                    ['Now to 1 Hour',  11],
                    ['Next 1 to 3 Hours',  12],
                    ['Next 3 to 6 Hours',  13],
                    ['Next 6 to 9 Hours',  14],
                    ['Any Monday', 1],
                    ['Any Tuesday', 2],
                    ['Any Wednesday', 3],
                    ['Any Thursday', 4],
                    ['Any Friday', 5],
                    ['Any Saturday', 6],
                    ['Any Sunday', 0]
                  ]
  SORT_BY = [
              ["Date - Newest", :start_at_desc],
              ["Date - Oldest", :start_at],
              ["Status", :status],
              ["Game Name", :game],
              ["Host Name", :hostname]
            ]

  # relationships

  has_many :invites
  has_many :event_messages
  has_many :messages, :as => :notified_object
  belongs_to :user
  belongs_to :clan, -> { with_deleted }
  belongs_to :game_game_system_join
  belongs_to :recurring_event

  # delegate

  delegate :game, to: :game_game_system_join
  delegate :game_system, to: :game_game_system_join

  # validations

  validates :event_type, :title, :start_at, :play_type, :game_type, :duration, :allow_waitlist, :game_game_system_join_id,  presence: { message: "Required" }
  validates_presence_of :clan_id, :if => lambda { self.event_type == "clan_event" }, :message => "Required"
  validates :maximum_size, numericality: { greater_than_or_equal_to: 2, :message => "Must be greater than or equal to 2" }

  validate :valid_maximum_age
  validate :start_at_cannot_be_in_the_past
  validate :validate_user_for_clan_event, on: :create
  validate :validate_private_event, on: :create


  # scops

  scope :future_events, -> { not_cancelled.where("end_at > ?", Time.now) }
  scope :past_events, -> { where("end_at < ?", Time.now) }
  scope :not_cancelled, -> { where.not(status:  Event.statuses[:cancelled]) }
  scope :event_start_order, -> { order(:start_at) }
  scope :upcoming_events, -> { where("events.end_at > ? AND (events.status= ? OR events.status= ?)", Time.zone.now, Event.statuses[:pending_open], Event.statuses[:pending_full]) }
  scope :public_and_clan_events, -> { where("events.event_type = ? OR events.event_type = ?", Event.event_types[:public_event], Event.event_types[:clan_event]) }
  attr_accessor :private_invite_ids

  # callbacks

  after_save :do_invite, :calculate_clan_activity_level
  after_create :host_invite, :send_discord_message
  before_save :add_end_at
  after_initialize :change_status!


  # methods
  def system_abbr_with_pc_type
    abbr = game_system.abbreviation
    if abbr.present?
      case abbr
      when "PS3"
        abbr
      when "PS4"
        abbr
      when "WV"
        abbr
      when "XB1"
        abbr
      when "XB360"
        abbr
      when "PC"
        if pc_type.present?
          case pc_type
          when "battletag"
            'Battle.net'
          when "steam"
            'Steam'
          when "origin"
            'Origin'
          end
        else
           ''
        end
      else
         ''
      end
    else
      ''
    end
  end

  def start_at_cannot_be_in_the_past
    if start_at.present? && start_at < Date.today
      errors.add(:start_at, "Event Time Listed Has Already Passed")
    end
  end

  def valid_maximum_age
    if maximum_age.present? && minimum_age.present? && maximum_age < minimum_age
      errors.add(:maximum_age, "Maximum Age Must Be Greater Than Minimum Age")
      errors.add(:minimum_age, "Minimum Age Must Be Less Than Maximum Age")
    end
  end

  def validate_user_for_clan_event
    if event_type == "clan_event" && clan.present?
      if !(user_id == clan.host_id)
        clan_member = clan.clan_members.find_by_user_id(user_id)
        errors.add(:clan_id, "Your Rank In This Clan Has Not Permitted You To Post Events For This Clan") if !(clan_member.present? && clan_member.clan_rank.post_events?)
      end
    end
  end

  def validate_private_event
    if false #event_type == "private_event"
      if !(self.user.active_subscription.present?)
        errors.add(:event_type, "Private Events Require a Pro or Elite Subscription")
      end
    end
  end

  def host_invite
    if recurring_event?
      if add_founder?
        self.invites.create(user_id: self.user_id, status: "confirmed")
        self.players = 1
        self.remaining_players = (self.maximum_size - self.players)
        self.save
      else
        self.players = 0
        self.remaining_players = (self.maximum_size - self.players)
        self.save
      end
    else
      self.invites.create(user_id: self.user_id, status: "confirmed")
      self.players = 1
      self.remaining_players = (self.maximum_size - self.players)
      self.save
    end
  end

  def recurring_event?
    recurring_event_id.present?
  end

  def event_share_details

      data = "#{game.title} (#{game_system.abbreviation})\n" +
              "#{start_at.in_time_zone(user.timezone).strftime('%b-%e | %l:%M%p %Z').gsub('EDT', 'ET').gsub('EST', 'ET').gsub('MST','MT').gsub('PST', 'PT').gsub('CST','CT')}\n" +
              "Spots #{maximum_size} | Age Limits #{minimum_age}-#{maximum_age}\n\n" +
              "VIEW ROSTER\n"

  end

  def web_event_url
    "#{ENV['domain']}/events/#{token}"
  end

  def game_with_sytestem_abbr
    result = ""
    result = "#{game.try(:title)} "
    result = result + if game_system.try(:abbreviation) == 'PC'
      if pc_type == 'origin'
        '(Origin)'
      elsif pc_type == 'battletag'
        '(Battle.net)'
      elsif pc_type == 'steam'
        '(Steam)'
      else
        '(PC)'
      end
    else
      "(#{game_system.try(:abbreviation)})"
    end
    result
  end

  def clan_event_twitter_share_details
      data = "Game: #{game.title} (#{game_system.abbreviation})\n" +
              "Event Starts: #{start_at.strftime('%b-%e | %l:%M%p %Z').gsub('EDT', 'ET').gsub('EST', 'ET').gsub('MST','MT').gsub('PST', 'PT').gsub('CST','CT') }\n"
  end

  def send_discord_message
    Event.delay.discord_event_delever(id)
  end

  def self.discord_event_delever(id)
   event = Event.find_by_id(id)
   if event.present? && event.clan_event?
     event.send_to_discord_now
   end
  end

  def send_to_discord_now
    if clan_event?
      host = clan.host
      discord_auth =  host.authorizations.discord.last
      if discord_auth.present? && discord_auth.discord_channels.present?
         begin
          send_event_message(host, self, discord_auth.discord_channels, discord_auth.alert_all)
         rescue
         end
      end
    end
  end



  def future_event?
    end_at > Time.now
  end

  def invite_private_event_payers
    message_type = private_event? ? 'private_game_invitations' : public_event? ? 'public_game_invitations' : clan_event? ? 'clan_game_invitations': nil
    message = self.user.messages.find_or_create_by(message_type: message_type, notified_object: self)
    if private_invite_ids.present?
      if private_invite_ids.is_a?(Array)
        private_invite_ids.reject!(&:empty?)
      elsif private_invite_ids.is_a?(Hash)
        private_invite_ids.values
      end
      private_invite_ids.each do |user_id|
        invite = invites.find_or_create_by(user_id: user_id)
        invite.user.receipts.find_or_create_by(message: message, message_type: message.message_type)
      end
    end
  end

  def do_invite
    Event.delay.invite_all_clan_members self
  end

  def self.invite_all_clan_members
    Rails.logger.info "inviting all clan members..."
    if event.clan_event? && ["pending_open", "pending_full"].include?(event.status)
      message = event.user.messages.find_or_create_by(message_type: 'clan_game_invitations', notified_object: event)
      event.clan.clan_members.each do |clan_member|
        invite = event.invites.find_by(user_id: clan_member.user_id)
        invite = event.invites.create(user_id: clan_member.user_id, status: Invite.statuses[:clan_member]) unless invite.present?
        invite.user.receipts.find_or_create_by(message: message, message_type: message.message_type) if invite.present?
      end
    end
  end

  def calculate_clan_activity_level
    if event_type == "clan_event" && clan.present?
      activity_level = clan.calcuate_activity_level_rating
      activity_level = 3 if activity_level == 0
      clan.activity_level = activity_level
      clan.save
    end
  end

  def get_spot
    self.reload
    (self.players > self.maximum_size) ? "#{self.maximum_size} of #{self.maximum_size}" : "#{self.players} of #{self.maximum_size}"
	end

  def add_end_at
    if start_at_changed? || duration_changed?
      self.end_at = start_at + duration.minutes
    end
  end

  def set_status_and_shift_players_to_and_from_waitlist_to_player_list!

    if invites.confirmed.count == maximum_size #do nothing
      self.status = :pending_full
      # p "===================11111===================="
    elsif invites.confirmed.count < maximum_size
      # p "===================22222===================="
     # status pending open so we need to try get from waitlist
      if invites.waitlisted.present?
        if invites.waitlisted.count >= (maximum_size - invites.confirmed.count)
          invites_wt = invites.waitlisted.order(:confirmed_at).limit( maximum_size - invites.confirmed.count)
          invites_wt.update_all(status: Invite.statuses[:confirmed], confirmed_at: Time.now)
          invites_wt.each do |invite|
            invite.send_join_notification!
          end
          self.status = :pending_full
        else
          invites.waitlisted.update_all(status: Invite.statuses[:confirmed], confirmed_at: Time.now)
          invites.each do |invite|
            invite.send_join_notification!
          end
          self.status = :pending_open
        end

      else
        self.status = :pending_open
      end

    elsif invites.confirmed.count >= maximum_size
      # p "===================33333===================="
      invites_cnf = invites.confirmed.order('confirmed_at').limit((invites.confirmed.count-maximum_size))
      invites_cnf.update_all(status: Invite.statuses[:waitlisted])
      invites_cnf.each do |invite|
        invite.send_leave_notification!
      end
      self.status = :pending_full
    end
    self.players = invites.confirmed.count
    self.remaining_players = (maximum_size - self.players )
    self.save
  end

  # callback
  def change_status!
   if id.present? && [:pending_full, :pending_open].include?(status.to_sym) && end_at < Time.now
     self.status = :completed
     self.save(validate: false)
   end
  end

  def send_notification_for_event_updates
    # :pending, :confired, waitlisted
    message = self.user.messages.find_or_create_by(message_type: :event_modified, notified_object: self)
    message.receipts.destroy_all
    invites = self.invites.pending_or_confirmed_or_waitlisted.where('user_id != ?', user_id)
    invites.update_all(status: Invite.statuses[:pending])
    invites.each do |invite|
      invite.user.receipts.find_or_create_by(message: message, message_type: message.message_type)
    end
  end

  def make_cancel!
    # :pending, :confired, waitlisted
    self.status = :cancelled
    if self.save && self.cancelled?
      message = self.user.messages.find_or_create_by(message_type: :event_cancelled, notified_object: self)
      self.invites.pending_or_confirmed_or_waitlisted.each do |invite|
        invite.user.receipts.find_or_create_by(message: message, message_type: message.message_type)
      end
    end
  end

  def self.generate_unique_secure_token
    SecureRandom.base58(5)
  end

end
