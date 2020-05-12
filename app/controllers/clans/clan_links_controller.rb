class Clans::ClanLinksController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def index
  	@clan = Clan.find(params[:clan_id])

  end

  private

end