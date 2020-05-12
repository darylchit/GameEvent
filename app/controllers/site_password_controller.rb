class SitePasswordController < ApplicationController

  def index
  end

  def welcome
  end

  def create
    puts params[:password]
    puts Rails.configuration.site_password
    if params[:password][:password] == Rails.configuration.site_password
      cookies[:site_password] = Rails.configuration.site_password
      redirect_to site_password_welcome_path
    else
      flash[:error] = 'Incorrect password'
      redirect_to site_password_path
    end

  end

  def check_site_password
    # do nothing
  end
end
