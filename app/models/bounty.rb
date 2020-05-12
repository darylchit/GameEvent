class Bounty < Contract
	# status: Open, Claimed, Cancelled, Invoiced, Pending Payment Confirmation from Paypal, Payment Complete

	belongs_to :seller, :class_name => 'User', :foreign_key => "seller_id"
	belongs_to :buyer, :class_name => "User", :foreign_key => "buyer_id"
	has_many :contract_game_game_system_joins, :foreign_key => 'contract_id'
	

	extend Searchable
	def set_defaults
		self.contract_type = 'Bounty'
		if self.new_record?
			if !self.start_date_time.present?
				self.start_date_time = DateTime.now.advance(:minutes => 1)
			end
			self.duration = Bounty.default_duration
	    self.end_date_time = self.start_date_time.advance(:minutes => self.duration)
		end
	end

	def can_be_claimed_by_user?(user)
		#-------------------------
		# NOTE: Similar logic is in the Bounty model
		#-------------------------
		# user isn't blocked by seller
		can_claim = !user.is_blocked_by_user?(buyer)
		# user meets the minimum requirements
		can_claim = can_claim && user.meets_contract_preferences?(buyer)
		# user isn't claiming a paid contract as a minor
		can_claim = can_claim && user.can_create_paid_contracts? if price_in_cents > 0
		# user isn't the poster
		can_claim = can_claim && buyer != user
		# within the duration. NOTE: THIS IS DELIBERATELY DIFFERENT THAN CONTRACTS
		can_claim = can_claim && start_date_time.advance(:minutes => duration) > DateTime.now
		can_claim
	end

	def can_create_paid_contracts
		#errors.add(:price_in_dollars, 'must be 0') if !seller.can_create_paid_contracts? && price_in_cents > 0
		#not used for bounties
	end

	def confirmed_users_count
		count = 0 
		count += 1 if seller
		count += 1 if buyer
		count
	end

	def slots_available?
		confirmed_users_count < 2
	end

	def can_claim_paid_bounties
		errors.add(:price_in_dollars, 'must be 0') if !seller.can_create_paid_contracts? && price_in_cents > 0
	end

	def validate_games
		#-------------------------
		# NOTE: Similar logic is in the Contract model
		#-------------------------
		return if is_closed?
		has_invalid = false
		game_game_system_joins.each do |ggs|
			has_invalid = true if !buyer.has_game_system?(ggs.game_system)
		end
		errors.add(:game_game_system_joins, 'includes a game for a system you do not own') if has_invalid
	end

	def self.default_duration
		60
	end
end
