class Clans::ClanMembersController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  respond_to :html, :js

  def create
    @clan = Clan.friendly.find(params[:clan_id])
    @clan.add_member(member_params)
    @clan_member = @clan.active_member? current_user if current_user.present?
    respond_to do |format|
      # flash[:info] = "You are now a member of #{@clan.name}"
      format.js
    end
    # if !@clan.private? && @clan.autojoin?
    #   @clan.add_member(member_params)
    #   flash[:info] = "You are now a member of #{@clan.name}"
    #   redirect_to @clan
    # else
    #   @invite  = ClanInvite.find(params[:invite_id])
    #   if @invite.approved?
    #     @clan.add_member(member_params)
    #     flash[:info] = "You are now a member of #{@clan.name}"
    #     redirect_to @clan
    #   else
    #     flash[:danger] = "Could not join clan, try again"
    #     redirect_to @clan
    #   end
    # end
  end

  def index
    @clan = Clan.friendly.find(params[:clan_id])
    @clan_donation = @clan.clan_donations.new
    @clan_members = @clan.clan_members.includes(:clan_rank)
                        .where.not(user_id: @clan.host.id )
                        .order('clan_ranks.default_sort_order') rescue nil
                        # .page(params[:page])
                        # .per(params[:per_page])
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def edit
    @member = ClanMember.find(params[:id])
    @clan = @member.clan

    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def update
    @clan_member = ClanMember.find(params[:id])
    @clan = @clan_member.clan
    if @clan_member.update(member_params)
      cm = @clan_member.as_json
      cm["title"] = @clan_member.clan_rank.title
      respond_to do |format|
        format.html {redirect_to clan_clan_members_path(@clan)}
        format.js {render layout: false}
      end
    end
  end

  def destroy
    @member = ClanMember.find(params[:id])
    @clan = @member.clan
    @clan_member = @clan.active_member? current_user if current_user.present?
    if current_user == @member.clan.host || current_user == @member.user
      ClanMember.find(params[:id]).really_destroy!
    end
    respond_to do |format|
      format.js
    end
  end

  def restricted_join
    @member = false
    @clan = Clan.friendly.find(params[:clan_id])
    if params[:access_code].present? && ( params[:access_code].downcase == @clan.access_code.downcase)
      @clan.add_member(user_id: current_user.id, clan_id: @clan.id)
      @clan_member = @clan.active_member? current_user if current_user.present?
      @member = true
    else
      @member = false
    end
    respond_to do |format|
      format.js
    end
  end

  private
  def member_params
    params.require(:clan_member).permit(:user_id, :clan_id, :clan_rank_id)
  end

end
