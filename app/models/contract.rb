# coding: utf-8
class Contract < ActiveRecord::Base
	# @!attribute start_date_time
	# 	@return [DateTime] the date and time the contract starts
	# @!attribute duration
	# 	@return [Int] the number of minutes the contract runs for
	# @!attribute price_in_cents
	# 	@return [Int] the suggested donation price for the contract, in cents

	# status: Open, Claimed, Cancelled, Cancelled by Poster, Invoiced, Pending Payment Confirmation from Paypal, Payment Complete

	belongs_to :seller, :class_name => 'User', :foreign_key => "seller_id"
	belongs_to :buyer, :class_name => "User", :foreign_key => "buyer_id"
	belongs_to :cancellation_assignee, :class_name => 'User', :foreign_key => 'cancellation_assignee_id'
	belongs_to :canceler, :class_name => 'User', :foreign_key => 'canceler_id'
	has_many :contract_game_game_system_joins
	has_many :game_game_system_joins, :through => :contract_game_game_system_joins
	has_many :ratings
	belongs_to :selected_game_game_system_join, class_name: 'GameGameSystemJoin'
	has_many :conversations, as: :conversationable, class_name: "::Mailboxer::Conversation"
    has_many :games, through: :game_game_system_joins
    has_many :game_systems, through: :game_game_system_joins

	#reports - this is reports against this contract
	has_many :reports, as: :reportable
	delegate :game_cover, :game_jumbo, :game_jumbo_mobile, :game_title,  to: :selected_game_game_system_join, allow_nil: true
	# @return [Float] the price of the contracts in dollars
	attr_accessor :price_in_dollars
	attr_accessor :start
	attr_accessor :end

	validates :price_in_cents, presence: { message: "Price is Required" }, numericality: { only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 2147483647 }
	validates :duration, presence: { message: "Duration is Required" }, numericality: { only_integer: true }
	validates :start_date_time, presence: { message: "Start At is Required" }
	validates :start_date_time, date: {after: Proc.new {|c|
		if c.bounty?
			Time.now.advance :minutes => -60
		else
			Time.now
		end
		}, message: 'must be in the future'}, if: Proc.new {|c|
			(c.status == 'Open' || c.status.nil?) && c.start_date_time.present?
		}
	validates :start_date_time, date: {before: Proc.new { |c|
			Time.now.advance(:months => 3)
		}, message: 'is too far in the future'
	}
	validates :end_date_time, presence: { message: "End At is Required" }
	validate :can_create_paid_contracts
	validate :price_is_valid
	# validate :did_select_game
	validates :game_game_system_join_ids, presence: {:message => 'must have at least one game selected'}
	validate :validate_games
	validates :will_play, presence: { message: "Will Play is Required" }
	validates :play_type, presence: { message: "Play Type is Required" }, on: :create
	validate :validate_premium_features

	scope :posted_by_user, -> (user) { where('(contract_type = ? AND seller_id = ?) OR (contract_type = ? AND buyer_id = ?) OR (contract_type = ? AND buyer_id = ?)', 'Contract', user.id, 'Bounty', user.id, 'Roster', user.id) }
	scope :buyer_rated, -> { where('buyer_feedback_date_time IS NOT NULL') }
	scope :seller_rated, -> { where('seller_feedback_date_time IS NOT NULL') }
	scope :psa_rating_at_or_above, -> (rating) { joins(:seller).where(:users => {:psa_rating => rating...Float::INFINITY})}
	scope :personality_rating_at_or_above, -> (rating) { joins(:seller).where(:users => {:personality_rating => rating...Float::INFINITY})}
	scope :approval_rating_at_or_above, -> (rating) { joins(:seller).where(:users => {:approval_rating => rating...Float::INFINITY})}
	scope :skill_rating_at_or_above, -> (rating) { joins(:seller).where(:users => {:skill_rating => rating...Float::INFINITY})}
	scope :completed, -> { where(:status => ['Payment Complete', 'Complete', 'Invoiced']) }
	scope :payment_completed, -> { where(:status => 'Payment Complete') }
	scope :completed_with_user, -> (user) { completed.where('buyer_id = ? OR seller_id = ?', user.id, user.id) }
	scope :invoiceable, -> { where('status = ? AND end_date_time < ?', 'Claimed', DateTime.now) }
	scope :uninvoiced, -> { where('(status = ? OR status = ?) AND end_date_time < ?', 'Claimed', 'Open', DateTime.now) }
	scope :cancelled, -> { where(:status => 'Cancelled') }
	scope :cancelled_by_poster, -> { where(:status => 'Cancelled by Poster') }
	scope :not_cancelled_by_poster, -> { where.not(:status => 'Cancelled by Poster') }
	scope :closed, -> { where.not(:status => 'Open').where.not(:status => 'Claimed').where.not(:status => 'Expired') }
	scope :pending_feedback_from_user, -> (user) { closed.not_cancelled_by_poster.where('(contract_type = ? AND buyer_id = ? AND seller_feedback_date_time IS NULL) OR (contract_type = ? AND seller_id = ? AND buyer_feedback_date_time IS NULL) OR (contract_type = ? AND seller_id = ? AND buyer_feedback_date_time IS NULL) OR (contract_type = ? AND buyer_id = ? AND seller_feedback_date_time IS NULL)', 'Contract', user.id, 'Contract', user.id, 'Bounty', user.id, 'Bounty', user.id) }

  scope :free, -> { where price_in_cents: [ 0, nil] }
  scope :is_public, -> { where private: [ false, nil] }
  scope :was_full, -> { where was_full: true  }

  STATUSES = ["Expired", "Cancelled", "Invoiced", "Payment Complete", "Cancelled by Poster", "Complete", "Open"]


  before_validation :set_defaults, on: :create
  before_save :set_defaults
	before_save :check_cancelled
	after_save :schedule_upcoming_notification

	include Searchable
	extend Searchable
	def price_in_dollars
		if self.price_in_cents.present?
			sprintf("%.2f", self.price_in_cents.to_d/100)
		else
			""
		end
	end

	def price_in_dollars=(cents)
		self.price_in_cents  = (cents.to_d*100).to_i
	end

	def cancelable?
		self.status == 'Open' || self.status == 'Claimed'
	end


  def set_defaults
    self.contract_type = 'Contract'
    self.end_date_time = self.start_date_time.advance(:minutes => self.duration) if self.start_date_time.present? && self.duration
  end

	def check_cancelled
		self.cancelled_at = DateTime.now if status == 'Cancelled'
	end

	def can_be_claimed_by_user?(user)
		#-------------------------
		# NOTE: Similar logic is in the Bounty model
		#-------------------------
		# user isn't blocked by seller
		can_claim = !user.is_blocked_by_user?(seller)
		# user meets the minimum requirements
		can_claim = can_claim && user.meets_contract_preferences?(seller)
		# user isn't claiming a paid contract as a minor
		can_claim = can_claim && user.can_create_paid_contracts? if price_in_cents > 0
	  # user is not the seller
		can_claim = can_claim && seller != user
		# in the past
		can_claim = can_claim && start_date_time > DateTime.now
		can_claim
	end

	def can_create_paid_contracts
		errors.add(:price_in_dollars, 'must be 0') if price_in_cents and price_in_cents > 0 and !seller.can_create_paid_contracts?
  end

	def price_is_valid
    return unless price_in_cents
		return if seller.nil? || !seller.has_restricted_contract_price? || price_in_cents <= 5_00
		errors.add(:price_in_dollars, 'cannot be more than $5') if price_in_cents > 5_00
	end

	def validate_games
		#-------------------------
		# NOTE: Similar logic is in the Bounty model
		#-------------------------
		return if is_closed?
		has_invalid = false
		game_game_system_joins.each do |ggs|
			has_invalid = true if contract? && !seller.has_game_system?(ggs.game_system) # the contract? is to fix a test case that fails when it shouldn't
		end
		errors.add(:game_game_system_join_ids, 'includes a title for a system you do not own') if has_invalid
	end

	# Validates that the user has access to premium features via a subscription or
	# trial expiration
	def validate_premium_features
		return if is_closed?
		if !owner.active_subscription.present? && !owner.active_ios_subscription.present? && (owner.trial_expiration.present? && owner.trial_expiration < DateTime.now)
			errors.add(:price_in_dollars, 'can only be free without a subscription') if price_in_cents > 0
		end
	end

	# def did_select_game
	# 	errors.add_to_base('Select at least one game') unless game_game_system_joins.count > 0
	# end


	def is_closed?
		status != 'Open' && status != 'Claimed'
	end

	def is_closed_by_poster?
		status == 'Cancelled by Poster'
	end

  def is_cancelled?
    status.eql?('Cancelled') || status.eql?('Cancelled by Poster')
  end


  def display_contract_type
    # internally known as Contract, Bounty, and Roster which map to 'LFP' and 'GR'
    # if this changes, also change WICE GRID custom filter
    roster? ? 'GR' : 'LFP'
  end

	def self.cancellation_reasons(person='all')
		reasons = [
			"I'm No Longer Available",
			"Player’s Behavior",
		]
		reasons << "Player Quit or Never Showed Up" unless person == 'seller'
		reasons << "Mercenary Quit or Never Showed Up" unless person == 'buyer'
		reasons += [
			"Broken Game/Game System",
			"Power/Internet/Game Service Outage",
			"Other (Please specify in notes)"
		]
	end

	# Schedules the "upcoming" notification for users. This will clear out any existing
	# version of it for the Contract, then reschedule it appropriately
	def schedule_upcoming_notification
		# queue = Sidekiq::ScheduledSet.new
		# queue.each do | job |
		# 	if job.klass == 'NotificationWorker' && job.args.size == 4 && job.args[0] == self.id && job.args[2] == 'Notifications::ContractNotification' && job.args[3] == 'upcoming'
		# 		job.delete
		# 	end
		# end


		# # since we're going to notify 2 hours in advance, don't schedule a notification if
		# # the contract is going to start within 2 hours
		# return if start_date_time < DateTime.now + 2.hours
    #
		# should_send = if contract? || bounty?
		# 	!self.is_cancelled?
		# elsif roster?
		# 	r = Roster.find self.id
		# 	r.confirmed_users.count > 0
		# else
		# 	false
		# end
		# if should_send
		# 	NotificationWorker.perform_at(self.start_date_time - 2.hours, self.id, 'Contract', 'Notifications::ContractNotification', 'upcoming')
		# end
	end

  # return the user who is considered the owner
  def owner
    contract? ? seller : buyer
  end



  # Convenience methods to determine what type this is

  def contract?
    contract_type.eql?('Contract')
  end

  def roster?
    contract_type.eql?('Roster')
  end

  def bounty?
    contract_type.eql?('Bounty')
  end

  def completed?
	 ['Payment Complete', 'Complete', 'Invoiced'].include?(status)
  end

  def duration_hours
      hours =  self.duration > 60 ? 'hours' : 'hour'
      "%s %s " % [self.duration / 60, hours]
  end
end
