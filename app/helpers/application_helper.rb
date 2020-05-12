module ApplicationHelper

	def contract_filter_text(filters, type='Contract')
		# note: we intentionally skip Game because it gets pretty obvious with the cover
		text = []

		# username
		text << "Username: #{filters["users.username"]}" if filters["users.username"].present?

		# game system
		if filters["game_systems.id"].present?
			gs = GameSystem.find filters["game_systems.id"]
			gss =  []
			gs.each do |g|
				gss << g.title
			end
			text << "#{'Game System'.pluralize gss.count}: #{gss.join ', '}"
		end

		# will play
		text << "Will Play: #{filters["users.will_play"].join ', '}" if filters["users.will_play"].present? && filters["users.will_play"].size > 0

		# newb patience
		text << "Patience: #{filters["users.newbie_patience_level"].join ', '}" if filters["users.newbie_patience_level"].present? && filters["users.newbie_patience_level"].size > 0

		# contacts completed
		text << "Minimum Contracts Completed: #{filters["users.contracts_completed"][:fr]}" if filters["users.contracts_completed"].present? && filters["users.contracts_completed"][:fr].present? && filters["users.contracts_completed"][:fr].to_i  > 0

		# contract price
		if filters[:price_in_cents].present? && filters[:price_in_cents][:fr].present?
			text << 'Donation: ' + (filters[:price_in_cents][:fr].to_i > 0  ? 'Yes' : 'No')
		end

		# start date
		if filters[:start_date_time].present? && (filters[:start_date_time][:fr].present? || filters[:start_date_time][:to].present?)
			fmt = '%Y/%m/%d'
			t = 'Date Range: '
			if filters[:start_date_time][:fr].present? && filters[:start_date_time][:to].present?
				start = filters[:start_date_time][:fr]
				e = filters[:start_date_time][:to]
				t += "#{start.strftime(fmt)} - #{e.strftime(fmt)}"
			elsif filters[:start_date_time][:fr].present?
				start = filters[:start_date_time][:fr]
				t += "#{start.strftime(fmt)} - Future"
			else
				e = filters[:start_date_time][:to]
				t += "Now - #{e.strftime(fmt)}"
			end
			text << t
		end

		if filters[:duration].present? && filters[:duration][:fr].present? && filters[:duration][:fr].size > 0
			t = 'Duration: '
			durations_a = filters[:duration][:fr].map do |d, v|
				duration = d.split('_')[0].to_i/60
				"#{duration} #{"hour".pluralize duration}"
			end
			t += durations_a.join ', '
			text << t
		end

		text << "Mission: #{filters[:mission]}" if filters[:mission].present?
		text << "Class: #{filters[:player_class]}" if filters[:player_class].present?
		text << "Level: #{filters[:level][:fr]}+" if filters[:level].present? && filters[:level][:fr].present?

		raw "Filtering by: <span class=\"filters\">#{text.join(', ')}</span>" if text.size > 0
	end

	def short_time_ago_in_words(time)
		str = time_ago_in_words time
		str = str.gsub 'hours', 'hr.'
		str = str.gsub 'hour', 'hr.'
		str = str.gsub 'minutes', 'min.'
		str = str.gsub 'minute', 'min.'
		str = str.gsub 'seconds', 'sec.'
		str = str.gsub 'second', 'sec.'
	end

	def keys_present?(hash, *path)
		path.inject(hash) do |location, key|
			location.respond_to?(:keys) ? location[key] : nil
		end
	end

	def get_link_for_invite(event)
		link_string = ""
		link_path = ""
		method = ""
		if current_user

			if event.user == current_user && !event.recurring_event?
				link_string = "Edit Event"
				link_path = edit_game_roster_path(event)
				method = "get"
			else
				invite = event.invites.find_by_user_id(current_user.id)
				if invite.present?
					case invite.status
					when 'pending'
						link_string = "Join"
						link_path = invites_path(event)
						method = "post"
					when 'clan_member'
						link_string = "Join"
						link_path = invites_path(event)
						method = "post"
					when 'confirmed'
						link_string = "Leave"
						link_path = leave_invite_path(event, invite)
						method = "put"
					when 'declined'
						link_string = "Join"
						link_path = invites_path(event)
						method = "post"
					when 'waitlisted'
						link_string = "Leave"
						link_path = leave_invite_path(event, invite)
						method = "put"
					end
				else
					link_string = "Join"
					link_path = invites_path(event)
					method = "post"
				end
			end
		else
			link_string = "Join"
			link_path = new_user_session_path
			method = "get"
		end
		if event.status == "cancelled"
			link_path = cancelled_event_game_roster_path(event)
			method = "get"
		end
		return link_string, link_path, method
	end

	def get_IGN(event, user=nil)
		user ||= event.user
		ign = "N/A"
		if event.game_system.abbreviation.present?
			case event.game_system.abbreviation
			when "PS3"
			  ign = user.psn_user_name
			when "PS4"
			  ign = user.psn_user_name
			when "WV"
			  ign = user.nintendo_user_name
			when "XB1"
			  ign = user.xbox_live_user_name
			when "XB360"
			  ign = user.xbox_live_user_name
			when "PC"
				if event.pc_type.present?
					case event.pc_type
					when "battletag"
					  ign = user.battle_user_name
					when "steam"
					  ign = user.steam_user_name
					when "origin"
					  ign = user.origins_user_name
					end
				else
			  	 ign = user.steam_user_name
				end
			else
				ign = ""
			end
		end
		if ign.blank?
			ign = "N/A"
		end
		return ign
	end

	def link_if_cancelled_event(link)
		if event.status == "cancelled"
			return link = cancelled_event_game_roster_path(event)
		else
			if current_user.present?
				return link
			else
				return link = new_user_session_path
			end
		end
	end

	def method_if_cancelled_event(method)
		if event.status == "cancelled"
			return method = "get"
		else
			if current_user.present?
				return method
			else
				return method ="get"
			end
		end
	end
	def get_event_show_path(event)
		global_show_event_path(event)
=begin
		case event.event_type
		when "clan_event"
				 if event.clan_id.present?
				 	return clan_clan_event_path(Clan.with_deleted.find(event.clan_id).id, event)
				 else
					  return ""
				 end
		when "public_event"
				 return public_game_path(event)
		when "private_event"
				 return game_roster_path(event)
		end
=end
	end
end
