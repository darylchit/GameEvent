class Admin::DashboardController < ApplicationController
  before_filter :authenticate_admin!
  def index
    @pagetitle = 'Dashboard'

	@users = User.where("created_at >= ?", Time.now - 30.days).count
  end
end
