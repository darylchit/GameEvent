class UserSetting < ActiveRecord::Base
  belongs_to :user

  enum app_type: [:android, :iphone]
  
  serialize :allow_clan_messages, Array
	serialize :allow_clan_game_invitations, Array

  def total_psr
    total_personality + total_skill + total_respect
  end

  def total_personality
    personality + admin_personality
  end

  def total_skill
    skill + admin_skill
  end

  def total_respect
    respect + admin_respect
  end

  def total_event_completed
    event_completed + admin_event_completed + old_event_completed
  end

  def total_cancellation_count
    cancellation_count + admin_cancellation_count + old_cancellation_count
  end


end
