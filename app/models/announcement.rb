class Announcement < ActiveRecord::Base

  def self.current
    order("updated_at desc").first || new
  end

  def self.for_user(user)
    return self.current unless user and user.read_announcement_at
    where("updated_at > ?", user.read_announcement_at).order("updated_at desc").first || new
  end

  def exists?
    !new_record?
  end
end
