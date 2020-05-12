class Clans::ClanNoticesController < ApplicationController
  before_action :authenticate_user!
  before_action :is_host?, only: [:new, :edit]
  before_action :in_clan?, only: :show

  def show
    @notice = ClanNotice.find(params[:id])
    @clan = Clan.friendly.find(@notice.clan_id)
    @header = 'CLAN NOTICE'
    @is_clan = true
    render 'shared/_notice_show'
  end

  def new
    @is_clan = true
    @clan_id = params[:clan_id]
    @clan = Clan.friendly.find(@clan_id)
    @notice = :clan_notice
    render 'shared/_notice_form'
  end

  def create
    @clan = Clan.friendly.find(params[:clan_id])
    @new_notice = ClanNotice.new(allowed_params)
    @new_notice.assign_attributes(user_id: current_user.id, clan_id: @clan.id)
    if @new_notice.save
      flash[:success] = 'You have successfully posted a new notice.'
      redirect_to clan_path(@clan)
    else
      flash[:error] = @new_notice.errors.full_messages
      redirect_to clan_path(@clan)
    end
  end

  def edit
    @notice = ClanNotice.find(params[:id])
    @clan = Clan.find(params[:clan_id])
    respond_to do |format|
      format.js
    end
  end

  def update
    @clan = Clan.find(params[:clan_id])
    @clan_notice = ClanNotice.find(params[:id])
    if @clan_notice.update(allowed_params)
      flash[:success] = 'You have successfully update a notice.'
      redirect_to clan_path(@clan)
    else
      flash[:error] = @clan_notice.errors.full_messages
      redirect_to clan_path(@clan)
    end
  end

  def destroy
    @notice = ClanNotice.find(params[:id])
    @clan = Clan.find(@notice.clan_id)
    if @notice.destroy
      flash[:success] = 'Notice has been deleted.'
    else
      flash[:error] = 'Notice was not able to be deleted.'
    end
    render 'clans/clans/_delete_notice'
  end

  private

  def allowed_params
    params.require(:notice).permit(:title, :body, :clan_id, :expiration, :user_id)
  end

  def is_host?
    clan = Clan.find(params[:clan_id])
    unless clan.is_host?(current_user)
      flash[:error] = 'You must be the clan host to post notices.'
      redirect_to clan_path clan
    end
  end

  def in_clan?
    notice = ClanNotice.find(params[:id])
    clan = Clan.find(notice.clan_id)
    unless clan.users.ids.include?(current_user.id)
      flash[:error] = 'You must join a clan to read their notices.'
      redirect_to clan_path clan
    end
  end
end
