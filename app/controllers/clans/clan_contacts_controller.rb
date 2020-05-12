class Clans::ClanContactsController < ApplicationController
  before_action :authenticate_user!

  expose :clan, :build_clan

  respond_to :html, :js

  def create
    message = current_user.messages.create(message_type: 'clan_messages', subject: params[:message], notified_object: clan)
    reply = current_user.replies.create(message: message, subject: message.subject)
    clan.host.receipts.create(message: message, message_type: message.message_type, is_read: (clan.host_id == current_user.id) )
    clan.clan_members.preload(:user, :clan_rank).joins("left join clan_ranks on clan_ranks.id = clan_members.clan_rank_id").where('clan_members.user_id != ? AND clan_ranks.receive_contact = ?', clan.host_id, true).each do |member|
      if member.clan_rank.receive_contact?
        member.user.receipts.with_deleted.create(message: message, message_type: message.message_type, is_read: (member.user.id == current_user.id) )
      end
    end
    reply.send_app_notification
    respond_to do |format|
      format.html {redirect_to clan}
      format.js
    end

  end

  private

  def build_clan
    Clan.friendly.find(params[:clan_id])
  end
end
