class Clans::ClanApplicationsController < ApplicationController

  before_action :authenticate_user!
  before_action :clan
  before_action :application_reviewer, only: :show
  before_filter :is_application_reviewer!, except: [:create, :show]
  before_filter :clan_application, only: [:accept, :destroy]
  respond_to :html, :js

  def index
    @clan_applications = @clan.clan_applications.includes(:user => :system_avatar, :answers => [:question])
    respond_to do |format|
      format.html { redirect_to clan_path @clan}
      format.js {render layout: false}
    end
  end

  def create
    @clan_application = ClanApplication.new(clan_application_params)
    respond_to do |format|
      if @clan_application.save
        # redirect_url =  clan_path(clan_application.clan)
        format.js
        # flash[:notice] = "Application to join clan '#{@clan.name}' has been sent!"
        @clan_application.send_message
      else
        # flash[:success] = "Application is not Posted Please try again"
        format.js
        # redirect_url = clan_path(clan_application.clan)
      end
    end

  end

  def show
    @clan_application = @clan.clan_applications.with_deleted.includes(:user, :reviewer ,:answers => [:question]).find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def accept
    @clan.clan_members.create(user_id: @clan_application.user_id)
    @clan_application.update_attributes(reviewer_id: current_user.id, reviewed_at: Time.now, status: true)
    @clan_application_id =  @clan_application.id

    subj = "Clan Application Status Update"
    body = "#{@clan.name.upcase} Has Accepted Your Application"
    message = @clan_application.messages.create(message_type: 'clan_applications', subject: subj, body: body)
    @clan_application.user.receipts.create(message: message, message_type: message.message_type)


    @clan_application.update_attributes(deleted_at: Time.now)
    @total_pending = @clan.clan_applications.count
    # flash[:success] = "Application Accepted"
    @notification_controller = request.referer.include?('notifications')
    respond_to do |format|
      format.js
    end
    # redirect_to edit_clan_path(@clan)
  end

  def destroy
    @total_pending = @clan.clan_applications.count
    @clan_application_id =  @clan_application.id
    @clan_application.update_attributes(reviewer_id: current_user.id, reviewed_at: Time.now, status: false)


    subj = "Clan Application Status Update"
    body = "#{@clan.name.upcase} Has Rejected Your Application"
    message = @clan_application.messages.create(message_type: 'clan_applications', subject: subj, body: body)
    @clan_application.user.receipts.create(message: message, message_type: message.message_type)
    @clan_application.update_attributes(deleted_at: Time.now)
    # flash[:success] = "Application Rejected"
    @notification_controller = request.referer.include?('notifications')
    respond_to do |format|
      format.js
    end
    # redirect_to clan_clan_application_path(@clan, @clan_application)
  end


  private

  def clan_application_params
    params.require(:clan_application).permit(:clan_id, :user_id,
                                             answers_attributes: [:id, :question_id, :user_id, :clan_id, :answer])
  end

  def clan
    @clan = Clan.friendly.find(params[:clan_id])
  end

  def clan_application
    @clan_application = @clan.clan_applications.find(params[:id])
  end

  def application_reviewer
    @is_application_reviewer = true
    clan_member = @clan.clan_members.find_by_user_id(current_user.id)
    if @clan.is_host?(current_user)
    elsif clan_member.present? && clan_member.clan_rank.review_applications?
    else
      @is_application_reviewer = false
      # flash[:error] = "You are not Application reviewer"
      # redirect_to clan
    end
  end

  def is_application_reviewer!
    clan_member = @clan.clan_members.find_by_user_id(current_user.id)
    if @clan.is_host?(current_user)
    elsif clan_member.present? && clan_member.clan_rank.review_applications?
    else
      flash[:error] = "You are not Application reviewer"
      redirect_to clan
    end
  end
end
