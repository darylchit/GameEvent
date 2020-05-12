class Roster < Bounty
	# status: Open, Claimed, Cancelled, Invoiced, Pending Payment Confirmation from Paypal, Payment Complete

	has_many :contract_game_game_system_joins, :foreign_key => 'contract_id'
	has_many :invites, -> { order(position: :asc) }, :foreign_key => 'contract_id'
  has_one :roster_game, -> {limit(1)}, class_name: 'ContractGameGameSystemJoin', foreign_key: 'contract_id'

  delegate :game_cover, :game_jumbo, :game_jumbo_mobile, :game_title,  to: :roster_game, allow_nil: true

  has_many :users, through: :invites
  has_many :roster_messages

  validates :title, presence: { message: "is Required" }
  validates :max_roster_size, presence: { message: "is Required" }, numericality: { only_integer: true }
  validate :min_roster_size, on: :update

  after_update :update_waitlist!, if: :max_roster_size_changed?


  belongs_to :clan
  extend Searchable



  def set_defaults
    self.price_in_cents = 0
		self.contract_type = 'Roster'
    self.status ||=  'Open'
		if self.new_record?
			if !self.start_date_time.present?
				self.start_date_time = DateTime.now.advance(:minutes => 1)
			end
			self.duration ||= Bounty.default_duration
	    self.end_date_time = self.start_date_time.advance(:minutes => self.duration)
		end
	end

  def users_that_meet_contract_preferences_and_have_the_same_game_and_system
    return User.none unless public?
    User.
      meets_contract_preferences( owner ).
      with_game_game_system_join( game_game_system_joins.first.id ).
      where( notif_games: true ).
      where.not( id: [ owner.id ] + Block.where( blocked_user_id: owner.id ).pluck(:user_id) )
  end

  # has this user been invited to this roster?
  def invited? user
    users.include?(user)
  end

  def owner
    buyer
  end

  def pending_users
    users.merge(invites.pending)
  end

  def declined_users
    users.merge(invites.declined)
  end

  def confirmed_users
    users.merge(invites.confirmed)
  end

	def no_show_users
		users.merge(invites.no_show)
	end

  def waitlist_users
    users.merge(invites.waitlisted).order("invites.position asc" )
  end

  def interested_users
    # user whom should receive messages for any events for this roster
    User.where id: ( users.merge(invites.interested).ids << buyer_id )
  end

  def name
    "Roster %d" % max_roster_size
  end

  def invite_for u
    invites.find_by( user: u )
  end

  def full?
    roster_size = max_roster_size.nil? ?  2 : max_roster_size
    user_count = confirmed_users_count.nil? ? becomes(Bounty).confirmed_users_count : confirmed_users_count
    user_count >= roster_size
  end

  def slots_available?
    !full?
  end

  def slots_available
    [ max_roster_size - confirmed_users_count, 0 ].max
  end

  def update_waitlist!
    # if there are any opening spots, and we have a waitlist, invite them in.
    if slots_available? and waitlist_users.exists?
      invites.waitlisted.limit( slots_available ).each do | w |
        w.confirmed!
				NotificationWorker.perform_async(w.id, 'Invite', 'Notifications::EventInviteNotification', 'moved_from_waitlist')
      end
    end
  end

  def min_roster_size
    # make sure we have not shrunk the roster past the number of users attending
    if confirmed_users_count > max_roster_size
      errors.add( :max_roster_size, "can not be less than the number of confirmed users")
      return false
    end
  end

  def send_message body, subject
    # if there are no interested users, we will send it to the owner
    owner.send_message interested_users || owner, body, subject
  end

  def send_welcome_message user
    subj = "Invite from %s | %s (%s) | %s at %s" % [ owner.username, contract_game_game_system_joins.first.game_game_system_join.game.title, contract_game_game_system_joins.first.game_game_system_join.game_system.abbreviation, (start_date_time.in_time_zone(user.timezone).strftime "%m/%d"), (start_date_time.in_time_zone(user.timezone).strftime "%l:%M%P") ]
    body = "[roster id=\"%d\" invited_user_id=\"%d\"]" % [id, user.id]
    owner.send_message user, body, subj
  end

  def send_removed_message user
    subj = "%s has been removed from %s's Roster Event"  % [ user.username, owner.username ]
    body = "%s [roster id=\"%d\" invited_user_id=\"%d\"]" % [subj, id, user.id]
    # notify roster users
    #send_message body, subj
    # notify user being removed
    owner.send_message user, body, subj
  end

  def send_time_change_message user
      message = 'You will need to re-claim your spot on the roster'
      subj = "Time has been updated for %s's Roster Event"  % [ owner.username ]
      body = "%s. %s. [roster id=\"%d\" invited_user_id=\"%d\"]" % [subj, message, id,     owner.id]
    # notify roster users
    # invited user id passed in as temp fix for random invited user displaying
    #send_message body, subj
    owner.send_message user, body, subj
  end

  def send_cancelled_message
    subj = "%s's Roster Event has been Cancelled" % [ owner.username ]
    body = "%s. [roster id=\"%d\" invited_user_id=\"%d\"]" % [subj, id, owner.id]
    # notify roster users
    send_message body, subj
  end
   def remove_confirmed_and_waitlist
        invites.each do |i|
            i.pending!
      end
  end

  def cancelled!
		self.status = 'Cancelled'
    self.canceler_id = buyer_id
    self.cancellation_assignee_id = buyer_id if full? and public?
    self.was_full = full?
    send_cancelled_message
    self.user_ids = []
    self.save
  end

  def complete!
		self.status = 'Complete'
    self.was_full = full?
    self.save
    update_contracts_completed!
  end

  def update_contracts_completed!
    # update owner and users invited users experience
    owner.update_contracts_completed!

    confirmed_users.each do |u|
      u.update_contracts_completed!
    end
  end

  def expired!
		self.status = 'Expired'
    self.was_full = false
    self.save
  end

  def public?
    !self.private?
  end

  def confirmed_users_count
    # owner is now considered as an invited users
		1 + confirmed_users.count + no_show_users.count
  end


  private

  # since we are inheriting from contracts, we need to disarm, change some validations
  #

  def self.eligible_bounties current_user
		#-------------------------
		# NOTE: Bounties switched to using roster type events
		#-------------------------
		bounties = Roster.is_public.where(contract_type: 'Roster').joins(:users)
		bounties = bounties.where.not('status' => 'Cancelled')

		#-------------------------
		# NOTE: Similar logic is in ContractsController and the User model
		#-------------------------
    #why were we suddenly deciding the class should be a bounty?
		bounties = bounties.where('start_date_time > ?', Time.now.advance(:minutes => -1*Bounty.default_duration))
		bounties = bounties.where('"users"."required_personality_rating" <= ?', current_user.personality_rating) if current_user.personality_rating > 0
		bounties = bounties.where('"users"."required_approval_rating" <= ?', current_user.approval_rating) if current_user.approval_rating > 0
		bounties = bounties.where('"users"."required_skill_rating" <= ?', current_user.skill_rating) if current_user.skill_rating > 0
		bounties = bounties.where('"users"."required_cancellation_rate" >= ?', current_user.cancellation_rate) if current_user.cancellation_rate.present?

  	bounties = bounties.free unless current_user.can_create_paid_contracts?

		bounties
	end

  def self.eligible_bounties_with_my_games current_user
    # no games, no point
    return Roster.none unless current_user.game_game_system_joins.exists?

    eligible_bounties(current_user).joins(:game_game_system_joins).merge(GameGameSystemJoin.where(id: current_user.game_game_system_joins.ids))
  end
end
