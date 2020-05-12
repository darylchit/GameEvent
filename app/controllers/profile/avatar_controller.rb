class Profile::AvatarController < ActionController::Base
	before_filter :authenticate_user!
	respond_to :html, :js

  def index
    @page = [params[:page].present? ? params[:page].to_i() : 1].max
    @total_pages = (SystemAvatar.all.count.to_f / 48.to_f).ceil
    @avatars = SystemAvatar.limit(48).offset((@page-1) * 48)
  end

end
