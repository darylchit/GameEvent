class Clans::ClanInvitesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def create
    @clan_invite = ClanInvite.new(invite_params)
    @clan = @clan_invite.clan

    if @clan_invite.save
      flash[:notice] = "Request to join clan '#{@clan.name}' has been sent!"
      @clan_invite.send_message
    else
      flash[:error] = "Request to join clan failed"
    end
    respond_to do |format|
      format.html {redirect_to clan_path(@clan)}
      format.js {render :layout => false}
    end

  end

  def update
    @invite = ClanInvite.find(params[:id])
    params = update_params
    if params[:status] == "confirmed" && @invite.user_id == @invite.inviter_id
      @invite.confirm current_user
      flash[:info] = "Welcome to the clan #{current_user.username}"
    elsif params[:status] == "confirmed" && @invite.user_id != @invite.inviter_id
      @invite.confirm current_user
      flash[:info] = "Clan member approved"
    elsif params[:status] == "declined"
      if @invite.deny current_user
        flash[:danger] = "#{@invite.user.username} declined as a clan member"
      end
    end
    redirect_to @invite.clan
  end

  def new
    @user = User.where(:id => params[:user_id]).last
    # TODO: pull off user model the clans that this user can actually invite other users to
    @available_clans = current_user.clans
  end

  private

    def invite_params
      params.require(:clan_invite).permit(:user_id, :clan_id, :inviter_id, :status)
    end

    def update_params
      params.require(:clan_invite).permit(:status)
    end
end
