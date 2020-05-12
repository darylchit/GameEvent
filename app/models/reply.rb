class Reply < ActiveRecord::Base
  belongs_to :message
  belongs_to :sender, polymorphic: true

  validates :subject, :message, :sender, presence: true
  default_scope { order(created_at: :desc) }

  #after_create :send_app_notification

  # TODO APP
  def send_app_notification
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
              options = { data: { title:  sender.username, message: subject, url: nil, id: receipt.id, type: message.message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: sender.username, body: subject, icon: "myicon", sound: "notificationRoster.wav", url: nil, id: receipt.id, type: message.message_type}, priority: "high"}
            end

            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)

          end
        end
      end
    end
  end

end
