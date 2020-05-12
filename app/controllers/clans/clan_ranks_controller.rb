class Clans::ClanRanksController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @clan_rank = ClanRank.new
  end

  def create
    @rank = ClanRank.new(clan_rank_params)

    if @rank.save
      flash[:success] = 'Rank settings have been updated'
    else
      flash[:error] = 'ERROR: Ranks were not updated'
    end
    respond_to do |format|
      format.html {redirect_to clan_path(@rank.clan)}
      format.js {render json: @rank.as_json}
    end
  end

  def index
    @clan = Clan.find(params[:clan_id])
    @ranks = @clan.clan_ranks.order(:level)
    respond_to do |format|
      format.html 
      format.js {render json: @ranks.as_json }
    end
  end

  def show
    @rank = ClanRank.find(params[:id])
    respond_to do |format|
      format.html {redirect_to clan_path(Clan.find(params[:clan_id]))}
      format.js {render json: @rank.as_json}
    end
  end

  def destroy
    @rank = ClanRank.find(params[:id])
    @clan = Clan.find(@rank.clan_id)
    @clan.remove_rank(params[:id])
    error = false
    if @clan.clan_ranks.count < 2
      error = "Clan only has one rank, can't delete"
    elsif @rank.clan != @clan
      error = "Rank doesn't belong to clan, contact support"
    elsif @rank == @clan.default_rank
      error = "Can't remove the clan's default rank"
    end
    if !error
      @clan.remove_rank(params[:id])
    end
    respond_to do |format|
      format.html {redirect_to clan_clan_ranks_path(@clan)}
      format.js {render json: @ranks.as_json }
    end
  end

  def edit
    @rank = ClanRank.find(params[:id])
  end

  def update
    @rank = ClanRank.find(params[:id])
    #params = clan_rank_params
    if @rank.update(clan_rank_params)
      flash[:success] = 'Rank settings have been updated'
    else
      flash[:error] = 'ERROR: rank was not updated'
    end
    respond_to do |format|
      format.html {redirect_to "/clans/#{@rank.clan_id}/clan_ranks"}
      format.js {render json: @rank.as_json}
    end
  end



  private

    def clan_rank_params
      params.require(:clan_rank).permit(:clan_id, :title, :level, permissions: [])
    end
end
