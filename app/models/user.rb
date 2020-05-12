class User < ActiveRecord::Base

	acts_as_token_authenticatable
	has_secure_token :web_token
	serialize :allow_clan_messages, Array
	serialize :allow_clan_game_invitations, Array
	belongs_to :charity
    has_many :subscriptions
    has_many :clan_notices
    has_one :active_subscription,  -> { active.web }, class_name: "Subscription"
	has_one :active_ios_subscription, -> { active.ios }, class_name: "Subscription"

	#other game-related relations
	has_many :game_game_system_user_joins
	has_many :game_game_system_joins, through: :game_game_system_user_joins
    alias_attribute :user_games, :game_game_system_joins
	has_many :games, through: :game_game_system_joins
	has_many :game_systems, through: :game_game_system_joins
	has_many :clan_applications
	has_many :answers
	has_many :video_urls, as: :video_urlable
	accepts_nested_attributes_for :video_urls, :allow_destroy => true, reject_if: proc { |attributes| attributes['url'].blank? }
	 validates_associated :video_urls

	#commenting out to test searchable associated scopes
    scope :with_game, -> (game_id) { includes(:games).where( games: { id: game_id } ) }
    scope :with_game_system, -> (game_system_id) { includes(:game_systems).where( game_systems: { id: game_system_id } ) }
    scope :with_game_game_system_join, -> (ggs_join_id) { includes(:game_game_system_joins).where( game_game_system_joins: { id: ggs_join_id } ) }

	has_many :ratings # ratings of other people
	has_many :my_ratings, foreign_key: "rated_user_id", class_name: "Rating" # ratings of me
	has_many :rated_users, through: :ratings, class_name: "User", foreign_key: "rated_user_id"

	#contracts
	has_many :posted_contracts, -> {where contract_type: 'Contract'}, class_name: "Contract", foreign_key: "seller_id"
	has_many :claimed_contracts, -> {where contract_type: 'Contract'}, class_name: "Contract", foreign_key: "buyer_id"
	has_many :cancelled_contracts, -> {where contract_type: 'Contract'}, class_name: "Contract", foreign_key: "canceler_id"
	has_many :assigned_cancelled_contracts, -> {where contract_type: 'Contract'}, class_name: 'Contract', foreign_key: 'cancellation_assignee_id'

	#bounties
	has_many :posted_bounties, -> {where contract_type: 'Bounty'}, class_name: "Bounty", foreign_key: "buyer_id"
	has_many :claimed_bounties, -> {where contract_type: 'Bounty'}, class_name: "Bounty", foreign_key: "seller_id"
	has_many :cancelled_bounties, -> {where contract_type: 'Bounty'}, class_name: "Bounty", foreign_key: "canceler_id"
	has_many :assigned_cancelled_bounties, -> {where contract_type: 'Bounty'}, class_name: 'Bounty', foreign_key: 'cancellation_assignee_id'

	#rosters
	has_many :rosters, -> {where contract_type: 'Roster'}, class_name: "Roster", foreign_key: "buyer_id"
	#moved method to association method to make includable
	has_many :open_rosters, -> {where('start_date_time > now()').where('max_roster_size > 1').where(:status => 'Open')}, class_name: "Roster", foreign_key: "buyer_id"
	has_many :cancelled_rosters, -> {where contract_type: 'Roster'}, class_name: "Roster", foreign_key: "canceler_id"
	has_many :assigned_cancelled_rosters, -> {where contract_type: 'Roster'}, class_name: 'Roster', foreign_key: 'cancellation_assignee_id'

	has_many :invites
	has_many :my_events, through: :invites, source: :event
	has_many :invited_rosters, through: :invites, source: :contract
	has_many :roster_messages
	has_many :invited_events, through: :invites, source: :event

	#clans
    has_many :clan_members, dependent: :destroy
	has_many :clans, through: :clan_members
	has_many :clan_messages
	has_one :own_clan,-> { with_deleted },  class_name: "Clan", primary_key: :id, foreign_key: :host_id

	has_one :user_setting

	#authorization
	has_many :authorizations

	#blocks
	has_many :blocks
	has_many :blocked_users, through: :blocks, class_name: "User", foreign_key: "blocked_user_id"
	has_many :blocked_by, :class_name => 'Block', :foreign_key => 'blocked_user_id'
	has_many :blocked_by_users, through: :blocked_by, :class_name => 'User', foreign_key: "user_id", source:  :user

	#favorites
	has_many :favorites
	has_many :favorited_by, :class_name => 'Favorite', :foreign_key => 'favorited_user_id'
	has_many :favorited_users, through: :favorites, foreign_key: 'favorited_user_id'

	has_many :clan_donations
	has_many :donations
	has_many :received_donations, class_name: 'Donation', foreign_key: 'donatee_id'

	belongs_to :system_avatar #speed up page loads by including system avatar
	#push
  has_many :devices, dependent: :restrict_with_error

	#reports - this is how many reports are against this user, not created by
	# @see {Report#created_by_user}
	has_many :reports, as: :reportable
	has_many :events
	has_many :recurring_events
	has_many :receipts, :as => :receiver
	has_many :messages, :as => :sender
	has_many :replies, :as => :sender

	validate :validate_minimum_image_size
	validate :validate_popular_links_of_user
	mount_uploader :avatar, AvatarUploader

	attr_accessor :skip_password_validation
	attr_accessor :do_profile_valdation
	attr_accessor :validate_game
	attr_accessor :do_country_validation

	attr_accessor :email_confirmation
	attr_accessor :age
	attr_accessor :validate_dublicate_ign
	attr_accessor :build_profile

    GAME_TYPE =  ["All Types", "Player vs. Player", "Player vs. Enemy"]
	  GAME_TYPE_FILTER = [["All Types", ''],
												["Player vs. Player", "All Types,Player vs. Player"],
												["Player vs. Enemy", "All Types,Player vs. Enemy"]]

	  GAME_STYLE = ["All Styles", "Casual", "Competitive"]
	  GAME_STYLE_FILTER = [["All Styles",''],
												 ["Casual", "All Styles,Casual" ],
												 ["Competitive", "All Styles,Competitive"]]

	  MOST_ACTIVE_DAYS = ["All Days", "Weekdays", "Weekends"]
	  MOST_ACTIVE_DAYS_FILTER = [['All Days', ''],
															 ['Weekdays', 'All Days,Weekdays'],
															 ['Weekends', 'All Days,Weekends']]

	  MOST_ACTIVE_TIMES = ["All Times", "Morning", "Daytime", "Afternoon", "Night"]
	  MOST_ACTIVE_TIMES_FILTER = [["All Times",''],
																["Morning", 'All Times,Morning'],
																["Daytime", 'All Times,Daytime'],
																["Afternoon",'All Times,Afternoon'],
																["Night", 'All Times,Night']]


	#can be modfied as necessary

    AGE_RANGES = {"13-18": "#{Date.today - 18.years} - #{Date.today - 13.years}",
                 "19-26": "#{Date.today - 26.years} - #{Date.today - 19.years}",
    			 "27-35": "#{Date.today - 35.years} - #{Date.today - 27.years}",
    			 "36-55": "#{Date.today - 55.years} - #{Date.today - 36.years}",
					"56+":	"#{Date.today - 1000.years} - #{Date.today - 56.years}"}

    EXPERIENCE_RANGES = (1..100).to_a.each_slice(10).to_a.map{|v| v = "#{v.first} - #{v.last}"}
		HOST_EXPERIENCE_RANGES = {
										 "Top 10%": "1 - 10",
                     "Top 20%": "1 - 20",
                     "Top 30%": "1 - 30",
                     "Top 40%": "1 - 40",
                     "Top 50%": "1 - 50",
										 "Top 60%": "1 - 60",
										 "Top 70%": "1 - 70",
										 "Top 80%": "1 - 80",
										 "Top 90%": "1 - 90"

                    }

    RATING_RANGES = {"No Requirements": "",
				             "Top 10%": "1 - 10",
                     "Top 20%": "1 - 20",
                     "Top 30%": "1 - 30",
                     "Top 40%": "1 - 40",
                     "Top 50%": "1 - 50"
                    }
		HOST_RATING_RANGES = {"Select Host PSA": "",
										 "Top 10%": "1 - 10",
										 "Top 20%": "1 - 20",
										 "Top 30%": "1 - 30",
										 "Top 40%": "1 - 40",
										 "Top 50%": "1 - 50"
		}



	IGN_USER_NAME_FIELD = [:psn_user_name, :xbox_live_user_name, :nintendo_user_name, :battle_user_name, :origins_user_name, :steam_user_name]
	IGN_NAME_AND_LABLE = {
			psn_user_name: 'PSN Online ID',
			xbox_live_user_name: 'Xbox Gamertag',
			nintendo_user_name: 'Nintendo ID',
			battle_user_name: 'Battle.net ID',
			origins_user_name: 'Origins ID',
			steam_user_name: 'Steam ID'

	}
	CANCELLATION_RATES =
									{
										'0 - 10': 0..10,
										'11 - 20': 11..20,
										'21 - 30': 21..30,
										'31 - 40': 31..40,
										'41 - 50': 41..50,
										'51 - 60': 51..60,
										'61 - 70': 61..70,
										'71 - 80': 71..80,
										'81 - 90': 81..90,
										'90 - 100': 90..100
									}

	# Include default devise modules. Others available are:
	# , :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	  :recoverable, :rememberable, :trackable, :validatable, :confirmable
	devise :omniauthable, :omniauth_providers => [:discord]

	#validation Sign up
	validate :validate_email_matches, :if => :new_record?
	# validates :email, presence: true, uniqueness: { :case_sensitive => false }
	validates :username, uniqueness: { :case_sensitive => false }
	validates_format_of :username, :with => /\A[a-zA-Z0-9_-]{4,32}\Z/i, message: :bad_username
	validates :date_of_birth, presence: { message: "Date of Birth is Required" }, if: 'age.nil?'
	validates :date_of_birth, date: { message: "Date of Birth is Required" }, if: :date_of_birth
	validates :date_of_birth, date: {before: Proc.new {Time.now}, message: 'must be in the past'}, if: :date_of_birth
	validates :age, presence: { message: "Required" }, if: 'date_of_birth.nil?'
	validates :age, numericality: { only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 2147483647 }, if: 'age.present?'


	#validation build your profile
	validate  :validate_country, if: :build_profile
	validates :language, presence: { message: "Language is Required" }, if: :build_profile
	validates :timezone, presence: { message: "TimeZone is Required" }, if: :build_profile
	validates :most_active_days, presence: { message: "Most Active Days is Required" }, if: :build_profile
	validates :most_active_time, presence: { message: "Most Active Time is Required" }, if: :build_profile
	validates :motto, presence: { message: "Motto is Required" }, if: :build_profile
  validates_length_of :motto, :maximum => 40, message: "Motto should be 40 character.", if: :build_profile

	validates :paypal_email, confirmation: { message: "The Updated PayPal Email Does Not Match Your Confirm Updated PayPal Email"}
	validates :email, confirmation: {message: "The Updated Contact Email Does Not Match Your Confirm Updated Contact Email"}, if: :build_profile


	validates :psn_user_name, uniqueness: { :case_sensitive => false }, if: :validate_dublicate_ign,:allow_blank => true
	validates :xbox_live_user_name, uniqueness: { :case_sensitive => false }, if: :validate_dublicate_ign, :allow_blank => true
	validates :nintendo_user_name, uniqueness: { :case_sensitive => false }, if: :validate_dublicate_ign, :allow_blank => true
	validates :battle_user_name, uniqueness: { :case_sensitive => false }, if: :validate_dublicate_ign, :allow_blank => true
	validates :origins_user_name, uniqueness: { :case_sensitive => false }, if: :validate_dublicate_ign, :allow_blank => true
	validates :steam_user_name, uniqueness: { :case_sensitive => false }, if: :validate_dublicate_ign, :allow_blank => true
	validate :supplied_ign, if:  :build_profile



	validates_inclusion_of :newbie_patience_level, :in => %w{High Low Unknown},  allow_nil: true, allow_blank: true
	validates_inclusion_of :will_play, :in =>GAME_TYPE, allow_nil: true, allow_blank: true

	validate :chose_system_avatar
	validate :validate_games, if: :validate_game?



	before_create :set_default
	after_create :initialize_user_setting

	#TODO PROMOTIONAL ELITE
	after_create :assign_promotional_elite

	include Searchable

	#has_secure_token_size
	def self.generate_unique_secure_token
    SecureRandom.base58(20)
  end

	def initialize_user_setting
		self.create_user_setting unless UserSetting.find_by_user_id(self.id).present?
  end

  def set_default
    self.required_cancellation_rate = 100
    self.will_play = 'All Types'
    self.game_style = 'All Styles'
    self.newbie_patience_level = 'Low'
  end

	def name
		return username
	end

	def timezone_abbr
		if timezone.present?
			ActiveSupport::TimeZone.find_tzinfo(timezone).current_period.abbreviation
		end
	end

	def mailboxer_email(object)
		return email if notif_system && notif_email
	end

	def calculated_cancellation_rate
		total = experience

		if total >= 3
			return ( cancellations.to_d / total.to_d * 100).to_i
		else
			return nil
		end
	end

	def update_cancellation_rate!
    self.update  cancellation_rate: calculated_cancellation_rate
	end

  def cancellations
    assigned_cancelled_contracts.count +
      assigned_cancelled_bounties.count +
      assigned_cancelled_rosters.count +
      invited_rosters.closed.is_public.was_full.merge(Invite.no_show).count
  end

	def experience
	  posted_contracts.completed.count +
      claimed_contracts.completed.count +
      posted_bounties.completed.count +
      claimed_bounties.completed.count +
      rosters.completed.is_public.count +
      invited_rosters.completed.is_public.merge(Invite.confirmed).count
	end

	def event_experience
		user_setting.admin_event_completed + user_setting.old_event_completed + event_current_exp
	end

	def event_current_exp
		my_events.completed.public_and_clan_events.where('players >= 2').where(id:  invites.confirmed.pluck(:event_id)).count
	end

	def event_cancellation_count
		cancelled_count = Event.public_and_clan_events.where(user: self).where(remaining_players: 0).cancelled.count
		no_show_invite =  invites.no_show.pluck(:event_id)
		no_show_count = Event.completed.public_and_clan_events.where('id in (?)', no_show_invite).where(remaining_players: 0).count
		cancellation_count =  cancelled_count + no_show_count
	end

	def event_cancellation_rate
		cancellation_rate = 0
		cancellation_rate  = (( event_cancellation_count + user_setting.admin_cancellation_count + user_setting.old_cancellation_count).to_d / (event_experience.to_d+ event_cancellation_count) * 100).to_i rescue 0
		cancellation_rate
	end

  def rateable_users
    # all users that I should be able to rate
    invited_closed_rosters = invited_rosters.closed.merge(Invite.confirmed)
    @user_ids = []

    # users whom confirmed their invitation for closed rosters that I have created
    @user_ids += Invite.joins(:contract).merge( rosters.closed ).rateable.pluck(:user_id)

    # users that have created rosters that I have been invited too
    @user_ids += invited_closed_rosters.pluck(:buyer_id)

    # users whom confirmed their invitation for closed rosters that I have also confirmed, not including my self
    @user_ids += Invite.where( contract_id: invited_closed_rosters.ids ).rateable.where.not(user_id: id).pluck(:user_id)

 		@user_ids += posted_contracts.closed.pluck(:buyer_id)
    @user_ids += claimed_contracts.closed.pluck(:seller_id)
    @user_ids += posted_bounties.closed.pluck(:seller_id)
    @user_ids += claimed_bounties.closed.pluck(:buyer_id)

    User.where( id: @user_ids.uniq )
  end

  def unrated_users
    # rateable users that I have not yet rated
		event_rateable_users.where.not( id: rated_users.ids )
	end

	# this method is same as 'rateable_users'
	# so we can remove 'rateable_users' after live
	def event_rateable_users
		user_ids = Invite.confirmed.joins(:event)
				.where('events.id in (?) and invites.user_id != ?', invited_events.completed.ids, id)
				.pluck(:user_id)
		User.where( id: user_ids.uniq  )
	end


	def rated_contracts

		@posted_contracts = posted_contracts.seller_rated.order('created_at DESC')
		@claimed_contracts = claimed_contracts.buyer_rated.order('created_at DESC')

		@posted_bounties = posted_bounties.buyer_rated.order('created_at DESC')
		@claimed_bounties = claimed_bounties.seller_rated.order('created_at DESC')

		@contracts = @posted_contracts + @claimed_contracts + @posted_bounties + @claimed_bounties
		@contracts.sort_by{ |contract| contract.updated_at }.uniq.reverse!

	end

	def system_avatar
		if system_avatar_id.present?
			SystemAvatar.find system_avatar_id
		else
			nil
		end
	end

	def system_avatar_url
		if system_avatar_id.present?
			SystemAvatar.find(system_avatar_id).file_path
		else
			nil
		end
	end

	def system_avatar=(avatar)
		system_avatar_id = avatar.id
	end

	def age=(value)
		@age = value
		self.date_of_birth = Time.now - value.to_i.years if value.present?
	end

	def avatar_url
      return avatar.url if is_pro_or_elite? and avatar.present?
      if system_avatar_id.present?
        SystemAvatar.find(system_avatar_id).file_path
      else
        avatar.url
      end
	end

	def avatar_url_with_domain
		if is_pro_or_elite? and avatar.present?
			avatar.url
		else
			SystemAvatar.find(system_avatar_id).file_path
		end
	end

	def calculate_trial_period(code)
		expiration = DateTime.now
		code = '' unless code.present?
		case code.downcase
		when 'free2play'
			expiration = expiration.advance :months => 1
		else
			expiration = expiration.advance :months => 0
		end
		self.trial_expiration = expiration
	end

	# Determines whether or not the user has premium access, given if we're loaded
	# from the mobile app. This assumes iOS for now if `is_mobile_app` is `true`
	#
	# @param is_mobile_app [Boolean] if the check should be performed under the context of the mobile app
	# @return [Boolean]
	def has_premium_access?(is_mobile_app)
		if is_mobile_app
			active_ios_subscription.present?
		else
			active_subscription.present? || trial_expiration.nil? || trial_expiration > DateTime.now
		end
	end

	def update_rating!
		# need to have feedback from more than 2 contracts in order to have your rating calculated
		 user_setting = self.user_setting

		 user_setting.personality = my_ratings.where(personality: true).count
		 user_setting.skill = my_ratings.where(skill: true).count
		 user_setting.respect = my_ratings.where(respect: true).count

		 user_setting.psr = user_setting.total_psr
		 user_setting.save
	end

	def can_create_paid_contracts?
    # meet age and paypal restrictions
		paypalable?
	end

	def update_contracts_completed!
    update contracts_completed: experience
	end

  # recalculate generosity rating for this user
  # based on paid contracts vs invoiced contracts
  def update_generosity_rating!
    # if user paid 100% of all asking donations
    max_donations = claimed_bounties.completed.sum(:price_in_cents) + claimed_contracts.completed.sum(:price_in_cents)

    if max_donations.zero?
      # using 0 for N/A, a user hasn't had an opportunity to make a donation
      rating = 0
    else
      # total amount user donated
      total_donations = claimed_bounties.payment_completed.sum(:price_in_cents) + claimed_contracts.payment_completed.sum(:price_in_cents) + donations.complete.sum(:amount_cents)
      # calculate fifth of max donations
      fifth = max_donations.div(5)

      # how many fifths of max_donations can go into total_donations
      rating = total_donations.div(fifth)

      # make sure rating is between 1..5
      rating = [1, rating ].max
      rating = [5, rating ].min
    end

    update_attribute( :generosity_rating, rating)
  end

	#allows admin to remove account by obsfucating information, while still preserving foreign key relationships
	def delete_account

		del_username = Digest::MD5.hexdigest(Time.now.to_s)
		del_email = del_username + '@example.com'
		del_dob = '1900-01-01'

		#obsfucate required unique values
		assign_attributes({username:del_username, email:del_email, date_of_birth:del_dob,
			psn_user_name:del_username, xbox_live_user_name:del_username, pc_user_name:del_username,
			nintendo_user_name:del_username})
		# set non-required personal info to nil
		self.first_name = nil
		self.last_name = nil
		self.address_1 = nil
		self.address_2 = nil
		self.country = nil
		self.state = nil
		self.zipcode = nil
		self.city = nil
		self.bio = nil
		self.paypal_email = nil
		self.avatar = nil
		self.ground_rules = nil
		self.twitch_video_url = nil
		self.youtube_video_url = nil
		#set deleted account boolean to true for view logic checks
		self.deleted_account = true
	end

	def has_restricted_contract_price?
		# users can only post up to $5 until they have been rated
		return self.psa_rating.nil? || self.psa_rating == 0
	end

	def is_blocking_user?(user)
		self.blocks.where(:blocked_user => user).count > 0
	end

	def is_blocked_by_user?(user)
		self.blocked_by.where(:user => user).count > 0
	end

	def is_favoriting_user?(user)
		self.favorites.where(:favorited_user => user).count > 0
	end

	def age
		#example of handling leap year birthdays, example from: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby
		age = Date.today.year - date_of_birth.year rescue nil
        age -= 1 if Date.today < date_of_birth + age.years rescue nil
        age
	end

	def favorite_by_user(user)
		self.favorites.where(:favorited_user => user).last
	end

	# evaluates whether this user model meets the contract preferences of the user passed in
	def meets_contract_preferences?(user)
		#-------------------------
		# NOTE: Similar logic is in BountiesController and ContractsController
		#-------------------------
		meets_prefs = true
		meets_prefs = meets_prefs && personality_rating >= user.required_personality_rating if personality_rating > 0
		meets_prefs = meets_prefs && skill_rating >= user.required_skill_rating if skill_rating > 0
		meets_prefs = meets_prefs && approval_rating >= user.required_approval_rating if approval_rating > 0
		meets_prefs = meets_prefs && psa_rating >= user.required_psa_rating if psa_rating > 0
		meets_prefs = meets_prefs && cancellation_rate <= user.required_cancellation_rate if cancellation_rate.present?

		meets_prefs
	end

  scope :meets_contract_preferences,  -> (u) {
    where( personality_rating: (u.required_personality_rating)..5).
    where( skill_rating: (u.required_skill_rating)..5).
    where( approval_rating: (u.required_approval_rating)..5).
    where( psa_rating: (u.required_psa_rating)..5).
    where( cancellation_rate: [nil, 0..(u.required_cancellation_rate)] )
  }

	def has_game_system?(game_system)
		abb = game_system.abbreviation
		# see if they have an IGN for the system
		ign = case abb
		when 'PC'
			self.steam_user_name.present? ? self.steam_user_name : self.battle_user_name.present? ? self.battle_user_name : self.origins_user_name
		when /^XB/
			self.xbox_live_user_name
		when /^WU/
			self.nintendo_user_name
		when /^NSW/
			self.nintendo_user_name
		when /^PS/
			self.psn_user_name
		else
			nil
		end

		ign.present?
	end

    def user_ign(game_system)
        #better way of doing this perhaps...
        abb = game_system.abbreviation
		ign = case abb
		when /^PC/
			self.pc_user_name
		when /^XB/
			self.xbox_live_user_name
		when /^Wii/
			self.nintendo_user_name
		when /^PS/
			self.psn_user_name
		else
			nil
		end

    end
	#---------------------------------
	# Language
	#---------------------------------
	# we're faking a has_many relationship
	def languages=(vals)
		self.language = (vals.select {|l| l.present?}).join ','
	end

	def languages
		language.present? ? language.split(',') : []
	end

	#---------------------------------
	# Validations
	#---------------------------------

	def profile_valid?
		country.present? && timezone.present? && language.present? && most_active_days.present? && most_active_time.present? &&
				motto.present? && (origins_user_name.present? || steam_user_name.present? || battle_user_name.present? || xbox_live_user_name.present? || nintendo_user_name.present? || psn_user_name.present?)
	end

	def new_ign_empty?
		!(origins_user_name.present? || steam_user_name.present? || battle_user_name.present?)
	end

	def supplied_ign
		errors.add(:base, 'You must provide at least one IGN') unless origins_user_name.present? || steam_user_name.present? || battle_user_name.present? || xbox_live_user_name.present? || nintendo_user_name.present? || psn_user_name.present?
	end

	def chose_system_avatar
		errors.add(:base, 'You must select an avatar') if self.do_profile_valdation && !avatar_url.present?
	end

	def validate_email_matches
		 if self.email.present? && self.email.downcase != self.email_confirmation.downcase
			 errors.add(:email_confirmation, 'does not match the provided email')
		 end
	end

	#---------------------------------
	# Options
	#---------------------------------
	def self.available_languages
		['English', 'Spanish', 'French', 'German', 'Portuguese', 'Japanese', 'Russian', 'Korean', 'Chinese', 'Hindi'].sort
	end

	def validate_games
		has_invalid = false
		bad_ggs = nil
		game_game_system_joins.each do |ggs|
			if !self.has_game_system?(ggs.game_system)
				has_invalid = true
				bad_ggs = ggs
			end
		end
		errors.add('Your titles ', "Added A Game For A System Without Providing An IGN - Please Add An IGN For #{bad_ggs.game_system.title}") if has_invalid
	end

	def validate_game?
	  self.validate_game == 'true' || self.validate_game == true
	end

  def validate_country
		errors.add(:country, :blank) unless valid_country?
  end

  def valid_country?
    # make sure country matches ISO 3611 codes
    country.present? and ISO3166::Country.translations.keys.include?(country)
  end

  def paypalable?
    # whether or not the user can use paypal
    # currently if the user lives in Puerto Rico, paypal is not valid.
    # also if we do not have a county assume the best
    !(valid_country? and country.eql?("PR"))
  end

  def has_announcements?
    Announcement.for_user(self).exists?
  end

  def all_rosters
    Roster.where('buyer_id = ? OR id in ( ? )', id, invited_rosters.ids)
  end

  # All Contracts associated to this user
  def all_contracts
    Contract.where('seller_id = ? OR buyer_id = ? OR id in ( ? )', id, id, invited_rosters.ids)
  end

  def finished_contracts
  	Contract.where('seller_id = ? OR buyer_id = ? OR id in ( ? )', id, id, invited_rosters.ids).where('status = ? OR status = ? OR status = ?', 'Complete', 'Invoiced', 'Payment Complete')
  end

  def active_contracts
    active_contract_ids =

      # Rosters I have been invited to and confirmed
      invited_rosters.merge(Invite.confirmed).ids +

      # Rosters that I have created and have at least one confirmed user
      rosters.joins(:invites).merge(Invite.confirmed).uniq.ids +

      # Claimed Contracts
      claimed_contracts.where(status: 'Claimed').ids +

      # Posted Contracts
      posted_contracts.where(status: 'Claimed').ids

    Contract.where( id: active_contract_ids )
  end



  def has_open_rosters?
  	open_rosters.present?
  end

	def upcoming_events
		# active_contract_ids =

		# 	# Rosters I have been invited to and confirmed
		# 	invited_rosters.merge(Invite.confirmed).ids +

		# 	# Rosters that I have created
		# 	rosters.ids +

		# 	# Claimed Contracts
		# 	claimed_contracts.where(status: 'Claimed').ids +

		# 	# Posted Contracts
		# 	posted_contracts.ids
    contract_ids = get_contract_ids
		Contract.where( id: contract_ids ).where('start_date_time > now()').where(status: ['Open', 'Claimed'])
	end

  def events
    contract_ids = get_contract_ids

    Contract.where( id: contract_ids )#.where(status: ['Open', 'Claimed'])
  end

  # Returns a list of game_game_system_user_joins (users games)
  # ordered by most played then release date
  def my_games
    # sort my games by release date
    by_release = games.order(:created_at).map{|g| g.id}
    # get the games from my events
    dgid = events.joins(:games).group('games.id').order('count(games.id) desc').count

    # Stick it into an array of game_ids
    mg = dgid.sort_by {|k,v| v}.reverse.map{|x| x[0]}
    # Add any games left out by release date
    ordering = mg + by_release.select{|id| !dgid[id]}
    # Return my game skus (game_game_system_user_joins)
    user_games.sort_by {|game| ordering.index game.game_id}[1..5]
  end

  def invite_for contract
    invites.find_by( contract: contract )
  end

  def has_subscription? subscription
    active_subscription and active_subscription.subscription_plan_id.eql?( subscription.id )
  end

  def has_subscription_expired?
    return false if active_subscription
    return false unless trial_expiration
    trial_expiration.past?

  end

  def can_invite_clan_members?
  	#Check if this user is in a clan and is a rank that has permission to invite members to the clan
  	false
  end

  def is_premium?
    # does this user have the right to access premium content via trial or paid subscription
    #for staging only
		#!has_subscription_expired?
		if active_subscription.present? && active_subscription.subscription_plan.name == 'Elite'
		  true
		else
			false
		end

	end

	def is_pro_or_elite?
		 active_subscription.present? && (active_subscription.pro? || active_subscription.elite? )
	end

  def get_systems_for_game game_id
    user_systems_for_game = []
    systems = GameGameSystemJoin.where(game_id: game_id)
    systems.each do |s|
      set = GameGameSystemUserJoin.where(game_game_system_join_id: s.id).where(user_id: self.id)
      unless set.empty?
        set.each do |r|
          user_systems_for_game << r.game_game_system_join_id
        end
      end
    end
    user_systems_for_game.map!{ |s| GameGameSystemJoin.find(s).game_system_id }
    return user_systems_for_game.uniq
  end

  # @method gets a user's clans, sorted by upcoming contracts for those clans.
  # The reason this method is used instead of simply returning current_user.clans
  # is because we have to return the clans ordered by upcoming contracts.
  # After sorting by clan event we then append the rest of the clans
  # that don't have upcoming events at the end.
  # @param User
  # @return array of hash of clans or empty array.
  def get_clans user = self
    set = Array.new
    user.clans.each{ |c| set << c.get_contracts_upcoming }
    contracts = set.flatten.sort_by{ |c| c.start_date_time }.map{ |c| Clan.find(c.clan_id) }.uniq
    contracts << user.clans.select{ |c| !contracts.include?(c) }
    return contracts.flatten
  end


  def check_links_present?
    @result = youtube? || twitch? || facebook? || google_plus? || twitter? || instagram? || battlelog? || patreon? || destiny? || guardian_gg? || steam? ||league_of_legends? || overwatch? || world_of_warcraft? || scuf? || mixer_url?
  end


  def validate_popular_links_of_user
    if battlelog.present? && battlelog.strip.include?('battlefield.com/')
    elsif battlelog.present?
      errors.add(:battlelog, "Battlelog: Enter Valid URL")
    end

    if guardian_gg.present? && guardian_gg.strip.include?('guardian.gg/')
    elsif guardian_gg.present?
    	errors.add(:guardian_gg, "Guardian GG: Enter Valid URL")
    end

    if destiny.present? && destiny.strip.include?('bungie.net/')
    elsif destiny.present?
    	errors.add(:destiny, "Destiny: Enter Valid URL")
    end

    if overwatch.present? && overwatch.strip.include?('playoverwatch.com/')
    elsif overwatch.present?
    	errors.add(:overwatch, "Overwatch: Enter Valid URL")
    end

    if steam.present? && steam.strip.include?('steamcommunity.com/')
    elsif steam.present?
    	errors.add(:steam, "Steam: Enter Valid URL")
    end

    if world_of_warcraft.present? && world_of_warcraft.strip.include?('worldofwarcraft.com/')
    elsif world_of_warcraft.present?
    	errors.add(:world_of_warcraft, "World of Warcraft: Enter Valid URL")
		end

		if scuf.present? && scuf.strip.include?('scufgaming.com/')
		elsif scuf.present?
			errors.add(:scuf, "Scuf: Enter Valid URL")
		end

		if mixer_url.present? && mixer_url.strip.include?('mixer.com/')
		elsif mixer_url.present?
			errors.add(:mixer_url, "Mixer: Enter Valid URL")
		end
  end

	#TODO PROMOTIONAL ELITE
	def assign_promotional_elite
		# if !active_subscription.present?
		# 	subscription_plan = SubscriptionPlan.find_by_name('Elite')
		# 	subscription = self.create_active_subscription(
		# 			subscription_plan: subscription_plan,
		# 			ends_on: 2.month.from_now,
		# 			profile_id: DateTime.now.to_s[-8],
		# 			token: DateTime.now.to_s[-8],
		# 			subscription_type: Subscription.subscription_types[:promotional]
		# 	)
		# end
	end

  private
  def get_contract_ids
    # Rosters I have been invited to and confirmed
    invited_rosters.merge(Invite.confirmed).ids +

      # Rosters that I have created
      rosters.ids +

      # Claimed Contracts
      claimed_contracts.where(status: 'Claimed').ids +

      # Posted Contracts
      posted_contracts.ids
	end

	def validate_minimum_image_size
    if !avatar_cache.nil? && (avatar.width < 400 || avatar.height < 400)
      errors.add(:avatar , "Avatar : should be 400 X 400 minimum!" )
    end
  end


end
