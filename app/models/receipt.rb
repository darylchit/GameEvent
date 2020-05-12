class Receipt < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :message
  belongs_to :receiver, polymorphic: true

  scope :unread, -> {where(is_read: false)}
  scope :read, -> {where(is_read: true)}

  after_create :send_app_notification


  # TODO APP
  def send_app_notification
    Rails.logger.info "sending notifications ..."
    if ['clan_invitations', 'private_game_invitations', 'public_game_invitations', 'clan_game_invitations', 'site_notice',
        'event_cancelled', 'event_modified', 'user_joins_roster', 'user_leaves_roster', 'clan_applications'].include?(message_type)
      user = receiver
      if user.is_a?(User)
        user_setting = user.user_setting
        if  user_setting.fcm_token.present? && (user_setting.android? || user_setting.iphone? )
          Rails.logger.info "user token: " + user_setting.fcm_token.to_s
          # fcm = FCM.new("AIzaSyCHC77aETrtuaAvNTQQqvnLhjFf6zHOSPc")
          fcm = FCM.new("AAAAqD6vl5g:APA91bEE1FUBihFLdW6kO9XpN-srDxlama2BzzjimePRN-kBlfq0tKMsblhNPW7a2_CeM1J0Pz7SMAYx4c_notZMCx2schfCDYvizOW6EYWAhnUsYA10azWOenextxFiUaFotLT8Z8er")
          if message.message_type == 'site_notice'
            if message.notified_object.is_a?(Blog)
            	title = message.notified_object.title
            	body = message.notified_object.value2
            elsif message.notified_object.is_a?(AdminConfig)
          		admin_config = message.notified_object
          		if admin_config.name == 'user_create_email'
          			title = AdminConfig.user_create_subject.value
          			body = AdminConfig.user_create_email.value2
          		elsif admin_config.name == 'clan_create_email'
          		  title = AdminConfig.clan_create_subject.value
          			body = AdminConfig.clan_create_email.value2
          		end
            end
            if user_setting.android?
              options = { data: { title: "Game Roster Support" , message: title, url: nil, id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: 'Game Roster Support', body: title, icon: "myicon", sound: "notificationRoster.wav", url: nil, id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
          elsif message.message_type == 'clan_invitations' && user_setting.allow_clan_invitations?
            # options = {data: {message: "#{message.sender.username} Has Invited You to Join #{message.notified_object.name}", url: "#{ENV['domain']}/clans/#{message.notified_object_id}", id: nil, type: :redirection}, collapse_key: :updated_score}
            if user_setting.android?
              options = { data: { title: "Clan Invitation | #{message.notified_object.name}" , message: "#{message.sender.username} Invited You To Join", url: "#{ENV['domain']}/clans/#{message.notified_object_id}", id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: 'Clan Inviatation', body: "#{message.notified_object.name}\nSent by: #{message.sender.username}", icon: "myicon", sound: "notificationRoster.wav", url: "#{ENV['domain']}/clans/#{message.notified_object_id}", id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
          elsif message.message_type == 'private_game_invitations' && user_setting.allow_private_game_invitations?
            # options = {data: {message: "Private Game Invite From: #{message.sender.username}", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: nil, type: :redirection}, collapse_key: :updated_score}
            event = message.notified_object
            body = "Event Starts: #{event.start_at.strftime("%b-%d | %l:%M%p")}\n#{event.game.title} (#{event.game_system.abbreviation})\nHosted By #{message.sender.username}"
            if user_setting.android?
              options = { data: { title: "Private Invite From #{message.sender.username}" , message: "#{event.start_at.strftime("%b-%d | %l:%M%p")} | #{event.game.title} (#{event.game_system.abbreviation})", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: 'Private Event Invite', body: body, icon: "myicon", sound: "notificationRoster.wav", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
          elsif message.message_type == 'public_game_invitations' && user_setting.allow_public_game_invitations?
            # options = {data: {message: "Public Game Invite From: #{message.sender.username}", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: nil, type: :redirection}, collapse_key: :updated_score}
            event = message.notified_object
            body = "Event Starts: #{event.start_at.strftime("%b-%d | %l:%M%p")}\n#{event.game.title} (#{event.game_system.abbreviation})\nHosted By #{message.sender.username}"
            if user_setting.android?
              options = { data: { title: "Public Invite From #{message.sender.username}" , message: "#{event.start_at.strftime("%b-%d | %l:%M%p")} | #{event.game.title} (#{event.game_system.abbreviation})", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: 'Public Event Invite', body: body, icon: "myicon", sound: "notificationRoster.wav", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
          elsif message.message_type == 'clan_game_invitations' && !(user_setting.allow_clan_game_invitations.include?(message.notified_object.clan_id.to_s))
            Rails.logger.info "sending notification to " + user.username
            # options = {data: {message: "Clan Game Invite From: #{message.sender.username}", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: nil, type: :redirection}, collapse_key: :updated_score}
            event = message.notified_object
            body = "Event Starts: #{event.start_at.strftime("%b-%d | %l:%M%p")}\n#{event.game.title} (#{event.game_system.abbreviation})"
            if user_setting.android?
              options = { data: { title: "Clan Event | #{event.clan.name}" , message: "#{event.start_at.strftime("%b-%d | %l:%M%p")} | #{event.game.title} (#{event.game_system.abbreviation})", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: "#{event.clan.name}", body: body, icon: "myicon", sound: "notificationRoster.wav", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
            Rails.logger.info "notification is sent to " + user.username
            Rails.logger.info "response: " + response.to_s
          elsif message.message_type == 'event_cancelled' && user_setting.allow_event_cancelled?
            # options = {data: {message: "#{message.sender.username} Has Cancelled Your Event", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: nil, type: :redirection}, collapse_key: :updated_score}
            event = message.notified_object
            body = "Event Starts: #{event.start_at.strftime("%b-%d | %l:%M%p")}\n#{event.game.title} (#{event.game_system.abbreviation})"
            if user_setting.android?
              options = { data: { title: "#{message.sender.username} Cancelled Your Event" , message: "#{event.start_at.strftime("%b-%d | %l:%M%p")} | #{event.game.title} (#{event.game_system.abbreviation})", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: "#{message.sender.username} Cancelled Your Event", body: body, icon: "myicon", sound: "notificationRoster.wav", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
          elsif message.message_type == 'event_modified' && user_setting.allow_event_modified?
            # options = {data: {message: "#{message.sender.username} Has Modifified Your Event", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: nil, type: :redirection}, collapse_key: :updated_score}
            event = message.notified_object
            body = "Event Starts: #{event.start_at.strftime("%b-%d | %l:%M%p")}\n#{event.game.title} (#{event.game_system.abbreviation})"
            if user_setting.android?
              options = { data: { title: "#{message.sender.username} Modified Your Event" , message: "#{event.start_at.strftime("%b-%d | %l:%M%p")} | #{event.game.title} (#{event.game_system.abbreviation})", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: "#{message.sender.username} Modified Your Event", body: body, icon: "myicon", sound: "notificationRoster.wav", url: "#{ENV['domain']}/events/#{message.notified_object.token}", id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
          elsif message.message_type == 'user_joins_roster' && user_setting.allow_user_joins_roster?
            # options = {data: {message: "#{message.sender.username}", url: "#{ENV['domain']}/events/#{message.notified_object.event.token}", id: nil, type: :redirection}, collapse_key: :updated_score}
            event = message.notified_object.event
            body = "Event Starts: #{event.start_at.strftime("%b-%d | %l:%M%p")}\n#{event.game.title} (#{event.game_system.abbreviation})"
            if user_setting.android?
              options = { data: { title: "#{message.sender.username} Joined Your Roster" , message: "#{event.start_at.strftime("%b-%d | %l:%M%p")} | #{event.game.title} (#{event.game_system.abbreviation})", url: "#{ENV['domain']}/events/#{event.token}", id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: "#{message.sender.username} Joined Your Roster", body: body, icon: "myicon", sound: "notificationRoster.wav", url: "#{ENV['domain']}/events/#{message.notified_object.event.token}", id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
          elsif message.message_type == 'user_leaves_roster' && user_setting.allow_user_leaves_roster?
            # options = {data: {message: "#{message.sender.username} Left Your Roster", url: "#{ENV['domain']}/events/#{message.notified_object.event.token}", id: nil, type: :redirection}, collapse_key: :updated_score}
            event = message.notified_object.event
            body = "Event Starts: #{event.start_at.strftime("%b-%d | %l:%M%p")}\n#{event.game.title} (#{event.game_system.abbreviation})"
            if user_setting.android?
              options = { data: { title: "#{message.sender.username} Left Your Roster" , message: "#{event.start_at.strftime("%b-%d | %l:%M%p")} | #{event.game.title} (#{event.game_system.abbreviation})", url: "#{ENV['domain']}/events/#{event.token}", id: id, type: message_type}, collapse_key: :updated_score}
            else
              options = {notification: {title: "#{message.sender.username} Left Your Roster", body: body, icon: "myicon", sound: "notificationRoster.wav", url: "#{ENV['domain']}/events/#{message.notified_object.event.token}", id: id, type: message_type}, priority: "high"}
            end
            registration_ids = [user_setting.fcm_token]
            response = fcm.send(registration_ids, options)
          elsif message.message_type == 'clan_applications' && user_setting.allow_clan_application?
            clan = message.notified_object.clan
            clan_application = message.notified_object
            if user.id  ==  message.notified_object.user_id
              #application status
              # options = {data: {message: "Application #{message.notified_object.status? ? 'Accepted' : 'Rejected'}", url: nil, id: nil, type: :clan_application_status}, collapse_key: :updated_score}
              body = "Applied To: #{clan.name}\nApplied On: #{clan_application.created_at.strftime("%b-%d | %l:%M%p")}"
              if user_setting.android?
                options = { data: { title: "Application #{message.notified_object.status? ? 'Accepted' : 'Rejected'}" , message: "Review The Application", url: nil, id: id, type: message_type}, collapse_key: :updated_score}
              else
                options = {notification: {title: "Application #{message.notified_object.status? ? 'Accepted' : 'Rejected'}", body: body, icon: "myicon", sound: "notificationRoster.wav", url: nil, id: id, type: message_type}, priority: "high"}
              end
              registration_ids = [user_setting.fcm_token]
              response = fcm.send(registration_ids, options)
            else
              #application
              # options = {data: {message: "#{message.notified_object.user.username} Applied to Clan #{clan.name}", url: nil, id: id, type: :clan_application}, collapse_key: :updated_score}
              body = "Applicant: #{clan_application.user.username}\nApplied To: #{clan.name}"
              if user_setting.android?
                options = { data: { title: "Clan Application | #{clan.name}" , message: "Review The Application", url: nil, id: id, type: message_type}, collapse_key: :updated_score}
              else
                options = {notification: {title: "Clan Application", body: body, icon: "myicon", sound: "notificationRoster.wav", url: nil, id: id, type: message_type}, priority: "high"}
              end
              registration_ids = [user_setting.fcm_token]
              response = fcm.send(registration_ids, options)
            end
          end
        else
          Rails.logger.info "user (" + user.username + ") hasn't got mobile app."
        end
      end
    end
  end


end
