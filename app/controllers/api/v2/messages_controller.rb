class Api::V2::MessagesController < Api::V2::BaseController

  include MessageQuery
  include UserPreferences

  before_filter :update_preferences_params, only: [:preferences, :filter]
  before_filter :update_push_preferences_params, only: [:push_preferences, :filter]
  expose :user_setting do
    current_user.user_setting
  end
  expose :my_clans, :build_my_clans
  expose :filter_clan_messages, :build_filter_clan_messages
  expose :filter_clan_game_invitations, :build_filter_clan_game_invitations
  expose :push_clan_messages, :build_push_clan_messages
  expose :push_clan_game_invitations, :build_push_clan_game_invitations

  expose :receipts do
    ids = []
    ids = ids + build_messages.ids if build_messages.present?
    ids = ids + build_clan_messages.ids if build_clan_messages.present?
    ids = ids + build_event_invitations.ids if build_event_invitations.present?
    ids = ids + build_event_notices.ids if build_event_notices.present?
    current_user.receipts.where('receipts.id in (?)', ids).includes(:message).order('created_at desc')
  end

  def index
    respond_with(receipts)
  end

  def create
    if params[:message].present? && params[:message][:subject].present? && params[:message][:clan_id].present?
      clan = Clan.with_deleted.find_by_id(params[:message][:clan_id])

      message = message = Message.find_by_message_type_and_body_and_notified_object_id('clan_messages', 'clan_chat', clan.id) if clan.present?
			if clan.present? && message.present?

        @receipt = current_user.receipts.find_or_create_by(message: message, message_type: message.message_type)
				clan_message = current_user.clan_messages.create(message: params[:message][:subject], clan_id: clan.id)
				message.receipts.update_all(created_at: Time.now)
	       message.receipts.each do|receipt|
	         receipt.update_attributes(deleted_at: nil, is_read: false) if receipt.receiver.id != current_user.id
	         receipt.update_attributes(deleted_at: nil, is_read: true) if receipt.receiver.id == current_user.id
	       end
	      clan_message.send_app_notification
			end

    elsif params[:message].present? && params[:message][:subject].present? && params[:message][:receiver].present? && params[:message][:receiver].is_a?(Hash)
      message = current_user.messages.create(message_type: :user_messages, subject: params[:message][:subject])
      params[:message][:receiver].each do|username,user_id|
        user = User.find_by_username_and_id(username, user_id)
        if user.present?
          user.receipts.create(message: message, message_type: message.message_type)
        end
      end
      @receipt = current_user.receipts.create(message: message, message_type: message.message_type, is_read: true)
      reply = current_user.replies.create(message: message, subject: message.subject)
      reply.send_app_notification
    end
  end

  private

  def build_my_clans
    current_user.clans.order(:name)
  end

  def build_filter_clan_messages
    allow_clans = []
    my_clans.each do |clan|
      allow_clans << [clan.id, clan.name, current_user.allow_clan_messages.include?(clan.id.to_s) ? false : true]
    end
    allow_clans
  end

  def build_push_clan_messages
    allow_clans = []
    my_clans.each do |clan|
      allow_clans << [clan.id, clan.name, user_setting.allow_clan_messages.include?(clan.id.to_s) ? false : true]
    end
    allow_clans
  end

  def build_filter_clan_game_invitations
    allow_clans = []
    my_clans.each do |clan|
      allow_clans << [clan.id, clan.name, current_user.allow_clan_game_invitations.include?(clan.id.to_s) ? false : true]
    end
    allow_clans
  end

  def build_push_clan_game_invitations
    allow_clans = []
    my_clans.each do |clan|
      allow_clans << [clan.id, clan.name, user_setting.allow_clan_game_invitations.include?(clan.id.to_s) ? false : true]
    end
    allow_clans
  end

end
