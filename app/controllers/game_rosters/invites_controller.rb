class GameRosters::InvitesController < ApplicationController
  expose :event, id: :game_roster_id
  expose :invite, scope: -> { event.invites }
  expose :invitations, :build_invitations
  expose :upcoming_events, :build_upcoming_events
  expose :events, :build_events
  expose :blocked_user_from_event_host, :build_blocked_users_from_event_host
  expose :blocked_user_from_event_age_limit, :build_blocked_users_from_age_limit
  expose :game_event_check, :build_game_event_check
  expose :public_preferences_validate, :build_public_preferences_validate
  expose :active_clan_member, :clan_member?

  respond_to :html, :js

  def create
    if params[:user].present?
      unless current_user.game_game_system_joins.find_by_id(event.game_game_system_join_id)
        current_user.game_game_system_joins << event.game_game_system_join
      end
      current_user.update(ign_params)
    end

    if active_clan_member || game_event_check || blocked_user_from_event_host.present? || blocked_user_from_event_age_limit.present? || public_preferences_validate
      # can't join the event
    else
      if (event.allow_waitlist == false) and ((event.invites.confirmed.count) >= event.maximum_size)
        @event_full = true
      else
        @invite = Invite.find_or_create_by(user_id: current_user.id, event_id: event.id)
        if event.players >= event.maximum_size
          @invite.status = :waitlisted
          @invite.confirmed_at = Time.now
          @invite.save
        else
          @invite.status = :confirmed
          @invite.confirmed_at = Time.now
          @invite.save
          @invite.send_join_notification!
        end
        event.players = event.invites.confirmed.count
        if event.players >= event.maximum_size
          event.status = :pending_full
          event.remaining_players  = 0
        else
          event.status = :pending_open
          event.remaining_players = event.maximum_size - event.players
        end
        event.save
      end
    end
  end

  def leave
    @invite = Invite.find_by_user_id_and_event_id(current_user.id, event.id)
    if @invite.present?
      @invite.update(status: :declined)
      @invite.send_leave_notification!
      event.set_status_and_shift_players_to_and_from_waitlist_to_player_list!
    end
  end

  def not_show
    if event.invites.where(user_id: current_user.id, status: 1).present?
      if event.completed?
        @invite = invite
        @invite.update(status: :no_show)
      end
    else
      @not_invite_confirmed_user = true
    end
  end

  def rate
    if event.invites.where(user_id: current_user.id, status: 1).present?
      if event.completed?
        @rating = current_user.ratings.find_by_rated_user_id(invite.user_id)
      end
    else
      @not_invite_confirmed_user = true
    end
  end

  def remove
    @invite = invite
    @invite_removed_id = @invite.id
    @invite.send_leave_notification!
    @invite_removed = @invite.destroy
    event.set_status_and_shift_players_to_and_from_waitlist_to_player_list!
  end

  private

  def ign_params
    params.require(:user).permit([:psn_user_name, :xbox_live_user_name, :nintendo_user_name, :battle_user_name, :origins_user_name, :steam_user_name])
  end

  def build_invitations
    Event.future_events.joins(:invites).where('invites.user_id' => current_user.id, 'invites.status' => Invite.statuses[:pending]).limit(3)
  end

  def build_upcoming_events
    Event.upcoming_events.joins(:invites).where('invites.user_id' => current_user.id, 'invites.status' => Invite.statuses[:confirmed]).limit(10)
  end

  def build_events
    Event.joins(:invites).where('invites.user_id' => current_user.id, 'invites.status' => Invite.statuses[:confirmed])
  end

  # check current user is block user
  def build_blocked_users_from_event_host
    if event.event_type == 'public_event' || event.event_type == 'clan_event'
      blocked_user_from_event_host = Block.where("user_id= ? and  blocked_user_id= ?", event.user_id, current_user.id)
    end
  end

  # check current user has age limit
  def build_blocked_users_from_age_limit
    event.minimum_age.present? ? minimum_age = event.minimum_age : minimum_age = 13
    event.maximum_age.present? ? maximum_age = event.maximum_age : maximum_age = 99
    if event.event_type == "public_event" || event.event_type == 'clan_event'
      if current_user.age >= minimum_age && current_user.age <= maximum_age
        blocked_user = false
      else
        blocked_user = true
      end
    end
  end

  def build_game_event_check
    game_error = false
    @ign_missing = false
    @game_missing = false
    if !current_user.game_game_system_joins.ids.include?(event.game_game_system_join_id)
      game_error = true
      @game_missing = true
    end

    if ['PS3', 'PS4'].include?(event.game_system.abbreviation) && !current_user.psn_user_name.try(:strip).present?
      game_error = true
      @ign_missing = true
    elsif ['XB360', 'XB1'].include?(event.game_system.abbreviation) && !current_user.xbox_live_user_name.try(:strip).present?
      game_error = true
      @ign_missing = true
    elsif ['NSW', 'WU'].include?(event.game_system.abbreviation) && current_user.nintendo_user_name.try(:strip).present?
      game_error = true
      @ign_missing = true
    elsif ['PC'].include?(event.game_system.abbreviation)
      if event.pc_type == 'battletag' && !current_user.battle_user_name.try(:strip).present?
        game_error = true
        @ign_missing = true
      elsif event.pc_type == 'origin' && !current_user.origins_user_name.try(:strip).present?
        game_error = true
        @ign_missing = true
      elsif event.pc_type == 'steam' && !current_user.steam_user_name.try(:strip).present?
        game_error = true
        @ign_missing = true
      end
    end

    game_error
  end

  def build_public_preferences_validate
    if event.public_event?
      if meet_cancellation_rate? == true && meet_personality? == true && meet_skill? == true && meet_respect? == true
        false
      else
        true
      end

    else
      false
    end
  end

  def meet_cancellation_rate?
    host = event.user
    host.required_cancellation_rate >= current_user.event_cancellation_rate
  end

  def meet_personality?
    meet_preferences = false
    host = event.user

    if host.required_personality_rating == 0
      meet_preferences = true
    else
      if current_user.user_setting.personality_percentile == 0
      elsif current_user.user_setting.personality_percentile <= host.required_personality_rating
          meet_preferences = true
      end
    end
    meet_preferences
  end

  def meet_skill?
    meet_preferences = false
    host = event.user

    if host.required_skill_rating == 0
      meet_preferences = true
    else
      if current_user.user_setting.skill_percentile == 0
      elsif current_user.user_setting.skill_percentile <= host.required_skill_rating
        meet_preferences = true
      end
    end
    meet_preferences
  end

  def meet_respect?
    meet_preferences = false
    host = event.user

    if host.required_approval_rating == 0
      meet_preferences = true
    else
      if current_user.user_setting.respect_percentile == 0
      elsif current_user.user_setting.respect_percentile <= host.required_approval_rating
        meet_preferences = true
      end
    end
    meet_preferences
  end

  def clan_member?
    if event.clan_event?
      !(event.clan.active_member? current_user)
    else
      false
    end
  end

end
