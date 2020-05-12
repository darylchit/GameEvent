attributes :message_type, :id, :receiver_id, :receiver_type, :message_id, :is_read, :trashed, :created_at
node(:f_created_at) do |receipt|
  receipt.created_at.strftime("%b-%-d")
end
child(:message => :message) do |message|
  attributes :id, :message_type, :body, :subject, :sender_id, :sender_type, :notified_object_id, :notified_object_type, :is_notice, :created_at

  if message.message_type == 'clan_applications'

    child(:notified_object) do
      attributes :id, :clan_id, :status, :created_at
      node(:applied_on) do |application|
        application.created_at.strftime("%b-%d | %l:%M%p")
      end
      node(:applicant) do|application|
       application.user.username
      end
      node(:applicant_id) do|application|
       application.user_id
      end
      node(:applicant_image) do |application|
        if application.user.avatar_url_with_domain.starts_with?('http')
          image_path application.user.avatar_url_with_domain
        else
          "#{ENV['domain']}#{image_path application.user.avatar_url_with_domain}"
        end
      end
      node(:image) do |application|
        if application.clan.cover_url_with_domain.starts_with?('http')
          image_path application.clan.cover_url_with_domain
        else
          "#{ENV['domain']}#{image_path application.clan.cover_url_with_domain}"
        end
      end

      node(:reviewer) do |application|
        application.reviewer.try(:username)
      end
      node(:reviewer_id) do |application|
        application.reviewer_id
      end
      attributes :reviewed_at
      node(:f_reviewed_at) do |application|
        if application.reviewed_at.present?
          application.reviewed_at.strftime("%b-%d | %l:%M%p")
        else
          application.reviewed_at
        end
      end
      child(:answers, :object_root => false) do
        node(:question) do |answer|
          answer.question.name
        end
        attributes :answer
      end
      child :clan do
        # clan attributes
        attributes :id, :name, :motto, :re_apply
      end
    end

  elsif message.message_type == 'user_messages' || message.message_type == 'clan_messages'
    if message.message_type == 'clan_messages'
      child :notified_object do
        # clan attributes
        attributes :id, :name, :motto
        node(:image) do |clan|
          if clan.cover_url_with_domain.starts_with?('http')
            image_path clan.cover_url_with_domain
          else
            "#{ENV['domain']}#{image_path clan.cover_url_with_domain}"
          end
        end
      end
    end
    node(:other_users) do
      message.receipts.with_deleted.count - 1
    end
    if message.message_type == 'clan_messages' && message.body == 'clan_chat'
      child(:clan_messages => :replies) do
        attributes :id
        node(:created_at) do |reply|
          reply.created_at.strftime("%b-%d | %l:%M%p")
        end
        node(:subject) do |reply|
         reply.subject.present? ? reply.subject.gsub(/[\r\n]+/, "\r\n") : " "
        end
        child(:sender) do
          attributes :id, :username
          node(:image) do |user|
           if user.avatar_url_with_domain.starts_with?('http')
             image_path user.avatar_url_with_domain
           else
             "#{ENV['domain']}#{image_path user.avatar_url_with_domain}"
           end
         end
        end
      end
    else
      child :replies do
        attributes :id
        node(:created_at) do |reply|
          reply.created_at.strftime("%b-%d | %l:%M%p")
        end
        node(:subject) do |reply|
         reply.subject.present? ? reply.subject.gsub(/[\r\n]+/, "\r\n") : " "
        end
        child(:sender) do
          attributes :id, :username
          node(:image) do |user|
           if user.avatar_url_with_domain.starts_with?('http')
             image_path user.avatar_url_with_domain
           else
             "#{ENV['domain']}#{image_path user.avatar_url_with_domain}"
           end
         end
        end
      end
    end
  elsif ['clan_game_invitations','private_game_invitations','public_game_invitations'].include?(message.message_type)
    child(:sender => :sender) do
      attributes :id, :username
      node(:image) do |user|
        if user.avatar_url_with_domain.starts_with?('http')
          image_path user.avatar_url_with_domain
        else
          "#{ENV['domain']}#{image_path user.avatar_url_with_domain}"
        end
      end
    end

    child(:notified_object) do |event|
      attributes :id, :title, :details
      node(:start_time) do |event|
        event.start_at.strftime("%b-%d | %l:%M%p")
      end
      node(:system) do |event|
        event.game_system.abbreviation
      end
      node(:game) do |event|
        event.game.title
      end
      node(:url) do |event|
        "/events/#{event.token}"
      end

      if message.message_type == 'clan_game_invitations'
        child(:clan) do
          attributes :id, :name, :motto
          node(:image) do
           image_path event.game.game_cover.url
          end
        end
      end
    end
  elsif ['event_reminder'].include?(message.message_type)

    child(:notified_object) do
      node(:url) do |event|
        "/events/#{event.token}"
      end
      node(:image) do |event|
        image_path event.game.game_cover.url
      end
      node(:line_1) do |event|
        'Upcoming Event Reminder'
      end
      node(:line_2) do |event|
        "Event Starts: #{event.start_at.strftime("%b-%d | %l:%M%p")}"
      end
      node(:line_3) do |event|
        "#{event.game.title} (#{event.game_system.abbreviation})"
      end
      node(:line_4) do |event|
        "Host: #{event.user.username}"
      end
    end

  elsif ['event_modified','event_cancelled'].include?(message.message_type)
    child(:sender => :host) do
      attributes :id, :username
    end


    node(:event_url) do |message|
      "/events/#{message.notified_object.token}"
    end

    child(:notified_object) do
      node(:url) do |event|
        "/events/#{event.token}"
      end
      node(:start_time) do |event|
        event.start_at.strftime("%b-%d | %l:%M%p")
      end
      node(:image) do |event|
        image_path event.game.game_cover.url
      end
      node(:system) do |event|
        event.game_system.abbreviation
      end
      node(:game) do |event|
        event.game.title
      end
    end

  elsif ['user_joins_roster', 'user_leaves_roster'].include?(message.message_type)

    node(:username) do |message|
      message.notified_object.user.username
    end

    node(:event_url) do |message|
      "/events/#{message.notified_object.event.token}"
    end

    child(:notified_object, :root => false) do
      child(:event) do
        node(:start_time) do |event|
          event.start_at.strftime("%b-%d | %l:%M%p")
        end
        node(:image) do |event|
          image_path event.game.game_cover.url
        end
        node(:system) do |event|
          event.game_system.abbreviation
        end
        node(:game) do |event|
          event.game.title
        end
        child(:user => :host) do
          attributes :id, :username
        end
      end
    end

  elsif ['clan_invitations'].include?(message.message_type)
    node(:sender_name) do |message|
      message.sender.username
    end
    child(:notified_object) do
      attributes :id, :name, :motto
      node(:image) do |clan|
        if clan.cover_url_with_domain.starts_with?('http')
          image_path clan.cover_url_with_domain
        else
          "#{ENV['domain']}#{image_path clan.cover_url_with_domain}"
        end
      end
      node(:mobile_image) do |clan|
        if clan.mobile_jumbo_url_with_domain.starts_with?('http')
          image_path clan.mobile_jumbo_url_with_domain
        else
          "#{ENV['domain']}#{image_path clan.mobile_jumbo_url_with_domain}"
        end
      end

    end
  elsif ['site_notice'].include?(message.message_type)
    if message.notified_object.is_a?(Blog)
      node(:subject) do
        "#{message.notified_object.title}"
      end
      node(:body) do
        "#{message.notified_object.value2}"
      end
    elsif message.notified_object.is_a?(AdminConfig)
       if message.notified_object.name == 'user_create_email'
         node(:subject) do
           "#{AdminConfig.user_create_subject.value}"
         end
         node(:body) do
           "#{AdminConfig.user_create_email.value2}"
         end
       elsif message.notified_object.name == 'clan_create_email'
         node(:subject) do
           "#{AdminConfig.clan_create_subject.value}"
         end
         node(:body) do
           "#{AdminConfig.clan_create_email.value2}"
         end
       end
    end
  end

end
