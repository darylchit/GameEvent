module AnnouncementsHelper
  def current_announcement
    @current_announcement ||= Announcement.current
  end
end
