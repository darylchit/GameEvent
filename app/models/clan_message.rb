class ClanMessage < ActiveRecord::Base
  belongs_to :clan
  belongs_to :user

  default_scope {order(created_at: :desc)}
  validates_presence_of :message, :message => "Message is Required"

  alias sender user
  # alias subject
  alias_attribute :subject, :message

  def send_app_notification
    message = Message.find_by_message_type_and_body_and_notified_object_id('clan_messages', 'clan_chat', clan_id)
    if message.present?
      message.receipts.unread.each do |receipt|
        user = receipt.receiver
        if user.is_a?(User) #&& user.user_setting.
          user_setting = user.user_setting
          allow_push = false
          if message.message_type == 'user_messages' && user_setting.allow_user_messages?
            allow_push = true
          end
          if message.message_type == 'clan_messages' && !(user_setting.allow_clan_messages.include?(message.notified_object_id.to_s))
            allow_push = true
          end
          if allow_push && (user_setting.android? || user_setting.iphone? ) && user_setting.fcm_token.present?
            # sky start

            # fcm = FCM.new("AIzaSyCHC77aETrtuaAvNTQQqvnLhjFf6zHOSPc")
            # options = {data: {message: "#{sender.username}: #{subject}", url: nil, id: receipt.id, type: :usermessages}, collapse_key: :updated_score}
            # registration_ids = [user_setting.fcm_token]
            # response = fcm.send(registration_ids, options)

            # sky end

            fcm = FCM.new("AAAAqD6vl5g:APA91bEE1FUBihFLdW6kO9XpN-srDxlama2BzzjimePRN-kBlfq0tKMsblhNPW7a2_CeM1J0Pz7SMAYx4c_notZMCx2schfCDYvizOW6EYWAhnUsYA10azWOenextxFiUaFotLT8Z8er")
            if user_setting.android?
              options = { data: { title: "#{clan.name} | #{sender.username}" , message: subject, url: nil, id: receipt.id, type: message.message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: clan.name, body: "Posted By #{sender.username}\n#{subject}", icon: "myicon", sound: "notificationRoster.wav", url: nil, id: receipt.id, type: message.message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)

          end
        end
      end
    end
  end

end
