class ClanAvatar < ActiveRecord::Base

  def avatar_path
    "clans/avatar/#{name}"
  end

  def jumbo_path
    "clans/jumbo/#{name}"
  end

  def mobile_jumbo_path
    "clans/mobile-jumbo/#{name}"
  end

end
