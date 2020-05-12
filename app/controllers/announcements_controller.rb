class AnnouncementsController < InheritedResources::Base
  def index
  end

  def read
    if user_signed_in?
      current_user.touch(:read_announcement_at)
    end
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end
end
