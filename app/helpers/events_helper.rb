module EventsHelper

  def event_status_icon event_status
    case event_status
      when "Cancelled"
        "fa-ban"
      when "Cancelled by Poster"
        "fa-ban"
      when "Expired"
        "fa-history"
      when "Invoiced"
        "fa-credit-card-alt"
      when "Payment Complete"
        "fa-credit-card-alt"
      when "Complete"
        "fa-check-circle"
      end
  end

  def other_user contract
    other_user = if contract.owner.eql?(current_user)
      contract.bounty? ? contract.seller : contract.buyer
    else # not the owner
      contract.owner
    end

    if other_user
      true
    else
      false
    end
  end
  
  def link_to_other_user contract
    # link to the other user of a contract.
    other_user = if contract.owner.eql?(current_user)
      contract.bounty? ? contract.seller : contract.buyer
    else # not the owner
      contract.owner
    end

    if other_user
		  link_to "#{profiles_path()}/#{other_user.username}" do
			  raw " #{other_user.username} "
			end
    else
      raw "&mdash;"
    end
  end

  def other_user_avatar contract
    # link to the other user of a contract with avatar.
    other_user = if contract.owner.eql?(current_user)
      contract.bounty? ? contract.seller : contract.buyer
    else # not the owner
      contract.owner
    end

    if other_user
      link_to "#{profiles_path()}/#{other_user.username}", class: "avatar-link" do
        image_tag other_user.avatar_url, class: 'avatar-xs'
      end
    else
      raw '<span class="avatar-link">&mdash;</span>'
    end

  end

  def other_user_media_object contract
    other_user = if contract.owner.eql?(current_user)
      contract.bounty? ? contract.seller : contract.buyer
    else # not the owner
      contract.owner
    end

    if other_user
      link_to "#{profiles_path()}/#{other_user.username}", class: "media-left" do
        image_tag other_user.avatar_url, class: 'avatar-xs media-object'
      end
    else
      raw '<span class="media-left"><span class="media-object">&mdash;</span></span>'
    end
  end
  
  #stripped out from event index view...oh my 
  def event_ign(contract, user)
    c = contract
    is_mine = contract.owner.eql?(current_user)
   if other_user c
     if is_mine
      if c.bounty? && c.seller.present? && c.selected_game_game_system_join.present? 
      link_to "#{profiles_path()}/#{c.seller.username}" do
        if c.selected_game_game_system_join.game_system.abbreviation == 'PS4' || c.selected_game_game_system_join.game_system.abbreviation == 'PS3'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.seller.psn_user_name.present? ? c.seller.psn_user_name : 'Not Listed'}")
          elsif c.selected_game_game_system_join.game_system.abbreviation == 'XB1' || c.selected_game_game_system_join.game_system.abbreviation == 'XB360'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.seller.xbox_live_user_name.present? ? c.seller.xbox_live_user_name : 'Not Listed'}")
        elsif c.selected_game_game_system_join.game_system.abbreviation == 'Wii U'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.seller.nintendo_user_name.present? ? c.seller.nintendo_user_name : 'Not Listed'}")
        elsif c.selected_game_game_system_join.game_system.title == 'PC'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.seller.pc_user_name.present? ? c.seller.pc_user_name : 'Not Listed'}")
         end
      end
    elsif c.contract? && c.buyer.present? && c.selected_game_game_system_join.present? 
      link_to "#{profiles_path()}/#{c.buyer.username}" do
        if c.selected_game_game_system_join.game_system.abbreviation == 'PS4' || c.selected_game_game_system_join.game_system.abbreviation == 'PS3'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.psn_user_name.present? ? c.buyer.psn_user_name : 'Not Listed'}")
          elsif c.selected_game_game_system_join.game_system.abbreviation == 'XB1' || c.selected_game_game_system_join.game_system.abbreviation == 'XB360'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.xbox_live_user_name.present? ? c.buyer.xbox_live_user_name : 'Not Listed'}")
        elsif c.selected_game_game_system_join.game_system.abbreviation == 'Wii U'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.nintendo_user_name.present? ? c.buyer.nintendo_user_name : 'Not Listed'}")
        elsif c.selected_game_game_system_join.game_system.title == 'PC'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.pc_user_name.present? ? c.buyer.pc_user_name : 'Not Listed'}")
          end
      end
    end
  else
    if c.bounty? && c.buyer.present? && c.selected_game_game_system_join.present? 
      link_to "#{profiles_path()}/#{c.buyer.username}" do
        if c.selected_game_game_system_join.game_system.abbreviation == 'PS4' || c.selected_game_game_system_join.game_system.abbreviation == 'PS3'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.psn_user_name.present? ? c.buyer.psn_user_name : 'Not Listed'}")
          elsif c.selected_game_game_system_join.game_system.abbreviation == 'XB1' || c.selected_game_game_system_join.game_system.abbreviation == 'XB360'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.xbox_live_user_name.present? ? c.buyer.xbox_live_user_name : 'Not Listed'}")
        elsif c.selected_game_game_system_join.game_system.abbreviation == 'Wii U'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.nintendo_user_name.present? ? c.buyer.nintendo_user_name : 'Not Listed'}")
        elsif c.selected_game_game_system_join.game_system.title == 'PC'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.pc_user_name.present? ? c.buyer.pc_user_name : 'Not Listed'}")
          end
      end
    elsif c.contract? && c.seller.present? && c.selected_game_game_system_join.present? 
      link_to "#{profiles_path()}/#{c.seller.username}" do
        if c.selected_game_game_system_join.game_system.abbreviation == 'PS4' || c.selected_game_game_system_join.game_system.abbreviation == 'PS3'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.seller.psn_user_name.present? ? c.seller.psn_user_name : 'Not Listed'}")
          elsif c.selected_game_game_system_join.game_system.abbreviation == 'XB1' || c.selected_game_game_system_join.game_system.abbreviation == 'XB360'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.seller.xbox_live_user_name.present? ? c.seller.xbox_live_user_name : 'Not Listed'}")
        elsif c.selected_game_game_system_join.game_system.abbreviation == 'Wii U'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.seller.nintendo_user_name.present? ? c.seller.nintendo_user_name : 'Not Listed'}")
        elsif c.selected_game_game_system_join.game_system.title == 'PC'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.seller.pc_user_name.present? ? c.seller.pc_user_name : 'Not Listed'}")
          end
      end
    elsif c.contract_type == 'Roster' && c.buyer.present?
      link_to "#{profiles_path()}/#{c.buyer.username}" do
        if c.contract_game_game_system_joins.first.game_game_system_join.game_system.abbreviation == 'PS4' || c.contract_game_game_system_joins.first.game_game_system_join.game_system.abbreviation == 'PS3'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.psn_user_name.present? ? c.buyer.psn_user_name : 'Not Listed'}")
          elsif c.contract_game_game_system_joins.first.game_game_system_join.game_system.abbreviation == 'XB1' || c.contract_game_game_system_joins.first.game_game_system_join.game_system.abbreviation == 'XB360'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.xbox_live_user_name.present? ? c.buyer.xbox_live_user_name : 'Not Listed'}")
        elsif c.contract_game_game_system_joins.first.game_game_system_join.game_system.abbreviation == 'Wii U'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.nintendo_user_name.present? ? c.buyer.nintendo_user_name : 'Not Listed'}")
        elsif c.contract_game_game_system_joins.first.game_game_system_join.game_system.title == 'PC'
          raw("<span class=\"hidden-lg hidden-md hidden-sm\" >IGN:&nbsp;</span>#{c.buyer.pc_user_name.present? ? c.buyer.pc_user_name : 'Not Listed'}")
          end
      end
     end
    end
 else
      raw "&mdash;"
  end
 end


 def link_url(event, user)
  c = event  


 if ((c.bounty? && c.seller.present?) || (c.contract? && c.buyer.present?)) || c.is_closed?
    if c.bounty?
      if c.buyer == user
        link_url = posted_bounty_path c
      else
        link_url = claimed_bounty_path c
      end
        elsif c.contract?
      if c.seller == user
        link_url = posted_contract_path c
      else
        link_url = claimed_contract_path c
        end
      else c.roster?
      link_url = roster_path c
    end
  else
    if c.bounty?
      if c.buyer == user
        link_url = edit_posted_bounty_path c
      else
        link_url = posted_bounty_path c
      end
    elsif c.contract_type == 'Contract'
      if c.seller == user
        link_url = edit_posted_contract_path c
      else
        link_url = posted_contract_path c
      end
    else
        link_url = roster_path c
    end

  end

end
 
 #logic extracted from _bounties_grid partial
 def public_event_actions(event, user)
      c = event 
      html = ''
      
      html += content_tag(:li, link_to("More Info", roster_path(c.id)))
      # Check if user already got an invite
      if  c.invited?(user)  #user.invites.where('contract_id' => c.id).exists?
        invite = c.invites.where(user: user).first 
        html += content_tag(:li, link_to("Join", claim_invite_path(invite), method: :post)) if invite.claimable?
        html += content_tag(:li, link_to("Waitlist", waitlist_invite_path(invite), method: :post)) if invite.waitlistable? 
      elsif c.can_be_claimed_by_user?(user)
        if c.slots_available?
          html += content_tag(:li, link_to("Join", roster_invites_path(c), method: :post))
        elsif c.waitlist
          html += content_tag(:li, link_to("Waitlist", roster_invites_path(c), method: :post))
        end 
      end
      html.html_safe
 end

 #logic extracted from /events/index view 
 def contract_actions(event, user)
  c = event 
  is_mine = c.owner.eql?(user)
  html= ''


  
  
  if c.contract?
    if c.status == 'Open' 
      html +=  content_tag(:li, link_to('Cancel',  posted_contract_cancel_path(c))) if is_mine
      html +=  content_tag(:li, link_to('Edit', edit_posted_contract_path(c)))  if is_mine
      html +=  content_tag(:li, link_to('Cancel', claimed_contract_cancel_path(c)))  if c.buyer_id == user.id
      html +=  content_tag(:li, link_to("Select", contract_path(c.id), remote: true)) if c.can_be_claimed_by_user?(user)
      #html +=  content_tag(:li, link_to("Select", contract_path(c.id), remote: true))) if c.is_claimable_by_user?(user)
    elsif c.status == "Claimed"
      html += content_tag(:li, link_to('Cancel', (is_mine ? posted_contract_cancel_path(c) : claimed_contract_cancel_path(c))))
      html += content_tag(:li,  link_to("View", link_url(c, user) ))
    elsif c.status == 'Invoiced'
      html +=  content_tag(:li, link_to('Donate', contract_payment_request_path(c), :method => "POST")) unless is_mine
      if is_mine && !c.buyer_feedback_date_time.nil?
        html += content_tag(:li,  link_to("View", link_url(c, user) ))
      elsif !is_mine && !c.seller_feedback_date_time.nil?
        html += content_tag(:li,  link_to("View", link_url(c, user) ))
      end
    else
      html += content_tag(:li,  link_to("View", link_url(c, user) ))
    end
      if c.is_closed? && !c.is_closed_by_poster? && c.status != 'Expired'
        if is_mine
          if c.buyer_feedback_date_time.nil?
            html += content_tag(:li, link_to('Rate', posted_contract_path(c) + '#event-rating'))
            html += content_tag(:li,  link_to("View", link_url(c, user) ))
          else
            html += content_tag(:li,  link_to("View", link_url(c, user) ))
          end
        else
          if c.seller_feedback_date_time.nil?
            html += content_tag(:li, link_to('Rate', posted_contract_path(c) + '#event-rating'))
            html += content_tag(:li,  link_to("View", link_url(c, user) ))
          else
            html += content_tag(:li,  link_to("View", link_url(c, user) ))
          end
        end
    end
  elsif c.bounty?
    if c.status == 'Open'
      html += content_tag(:li, link_to('Cancel', (is_mine ? posted_bounty_cancel_path(c) : claimed_bounty_cancel_path(c))))
      html += content_tag(:li, link_to('Edit', edit_posted_bounty_path(c)))  if is_mine
    elsif c.status == "Claimed"
      html += content_tag(:li, link_to('Cancel', (is_mine ? posted_bounty_cancel_path(c) : claimed_bounty_cancel_path(c))))
      html += content_tag(:li,  link_to("View", link_url(c, user) ))
    elsif c.status == 'Invoiced'
      html += content_tag(:li, link_to('Donate', bounty_payment_request_path(c), :method => "POST"))
      if is_mine && !c.buyer_feedback_date_time.nil?
        html += content_tag(:li,  link_to("View", link_url(c, user)))
      elsif !is_mine && !c.seller_feedback_date_time.nil?
        html += content_tag(:li,  link_to("View", link_url(c, user)))
      end
    end
    if c.is_closed? && !c.is_closed_by_poster? && c.status != 'Expired'
      if is_mine
        if c.seller_feedback_date_time.nil?
          html += content_tag(:li, link_to('Rate', posted_contract_path(c) + '#event-rating'))
          html += content_tag(:li,  link_to("View", link_url(c, user)))
        else
          html += content_tag(:li,  link_to("View", link_url(c, user)))
        end
      else
        if c.buyer_feedback_date_time.nil?
          html += content_tag(:li, link_to('Rate', posted_contract_path(c) + '#event-rating')) unless is_mine
          html += content_tag(:li,  link_to("View", link_url(c, user)))
        else
          html += content_tag(:li,  link_to("View", link_url(c, user)))
        end
      end
          end
     else # c.roster?
    if c.status == 'Open' && is_mine
           html +=  content_tag(:li, link_to('Cancel', cancel_roster_path(c)))
            html += content_tag(:li, link_to('Edit',  edit_roster_path(c))) 
          else
            html += content_tag(:li,  link_to("View", link_url(c, user)))
        end
    end

      html.html_safe
  end

  def game_photo_cover(contract)
    # The roster has one game so it's the first join, user that as a cover
    if contract.roster?
      
      contract.contract_game_game_system_joins.first.game_game_system_join.game.game_cover
    # The contract may have a game selected, use that cover
    elsif contract.selected_game_game_system_join_id.present?
      contract.selected_game_game_system_join.game.game_cover
    elsif contract.game_game_system_joins.present? && contract.game_game_system_joins.count == 1
      contract.game_game_system_joins.first.game.game_cover
    else
      contract.owner.avatar
    end
  end

  def game_photo_jumbo(contract)
    # The roster has one game so it's the first join, user that as a cover
    if contract.roster?
      contract.contract_game_game_system_joins.first.game_game_system_join.game.game_jumbo

    # The contract may have a game selected, use that cover
    elsif contract.selected_game_game_system_join_id.present?
      contract.selected_game_game_system_join.game.game_jumbo

    # The contract doesn't have a game selected, use the buyer's avatar
    else
      contract.owner.avatar
    end
  end

end
