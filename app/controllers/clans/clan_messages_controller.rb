class Clans::ClanMessagesController < ApplicationController

    before_action :check_if_owner, except: [:create]
    #before_action :ensure_user_can_post, only: [:create]
    respond_to :html, :js

    # enable_sync
  def index
    @clan = Clan.friendly.find(params[:clan_id])
    @clan_message = ClanMessage.new
    @clan_notices = @clan.clan_notices.current
  end

  def create
    message = params[:clan_message][:message]
    @clan = Clan.friendly.find(params[:clan_id])
    @clan_message = current_user.clan_messages.new(message: message, clan_id: @clan.id)
    if @clan_message.save
      sync_new @clan_message
      message = Message.find_by_message_type_and_body_and_notified_object_id('clan_messages', 'clan_chat', @clan.id)
      message.receipts.update_all(created_at: Time.now)
       message.receipts.each do|receipt|
         receipt.update_attributes(deleted_at: nil, is_read: false) if receipt.receiver.id != current_user.id
         receipt.update_attributes(deleted_at: nil, is_read: true) if receipt.receiver.id == current_user.id
       end
      @clan_message.send_app_notification
    end

    respond_with { @message }
  end

  def edit
    @clan_message = ClanMessage.find(params[:id])
    respond_to do |format|
        format.html {}
        format.js {render :layout => false}
    end
  end

  def update
    @clan_message = ClanMessage.find(params[:id])
    if @clan_message.update(clan_message_params)
        respond_to do |format|
            format.html {redirect_to clan_path(@clan_message.clan) + '#clan-messages'}
            format.js {render :layout =>false}
        end
    else
        respond_to do |format|
            format.html {render "edit"}
            format.js {render :layout => false, :status => 422 }
        end
    end
  end

  def destroy
    @clan_message.destroy
    sync_destroy @clan_message
    respond_to do |format|
        format.html {redirect_to clan_path(@clan_message.clan.id) + '#clan-messages'}
        format.js {render :layout => false}
    end
  end

  private
    def check_if_owner
      if params[:id]
        @clan_message = ClanMessage.find(params[:id])
        unless current_user == @clan_message.clan.host
            redirect_to clan_path(@clan_message.clan)
        end
      else
        false
      end
    end

    def clan_message_params
      params.require(:clan_message).permit(:message, :clan_id)
    end

    def valid_clan?(clan_id)
      Clan.exists?(id: clan_id)
    end

    def ensure_user_can_post
      if valid_clan?(params[:clan_id])
          clan = Clan.find(params[:clan_id])
          unless clan.invited?(current_user) || current_user == clan.owner
              redirect_to(:back, notice: 'Unauthorized to post on this clan')
          end
      else
          head(403)
      end
    end

    def notify_users(message)
      NotificationWorker.perform_async(message.id, 'ClanMessage', 'Notifications::ClanMessageNotification', 'created')
    end
end
