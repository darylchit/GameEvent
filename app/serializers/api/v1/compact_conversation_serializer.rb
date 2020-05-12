class Api::V1::CompactConversationSerializer < ActiveModel::Serializer
  attributes :id, :snippet, :recipients, :last_message_at, :unread, :has_contract

  def recipients
    (object.recipients.select{ |r| r.username != serialization_options[:current_user].username}).map do |r|
      unless r.nil? || r.deleted_account
        Api::V1::UserSerializer.new r, root: false
      else
        { username: '[deleted]', deleted_account: true }
      end
    end
  end

  def last_message_at
    object.messages.order(:created_at => :desc).first.created_at
  end

  def snippet
    if object.receipts.last.message.body == "I've claimed your contract" || object.receipts.last.message.body == "I've claimed your event"
      "I've claimed your event"
    else
      snippet = object.receipts.last.message.body.gsub(/\[[^\]]*\]/, '')[0..40]
      if snippet == ""
        if object.messages.first.body.index('invited_user_id').present?
          sender = object.messages.first.sender
          username = if sender.nil? || sender.deleted_account
            '[deleted]'
          else
            sender.username
          end
          "#{username} has invited you to an event"
        else
          object.subject
        end
      else
        snippet
      end
    end
  end

  def unread
    object.messages.last.is_unread? serialization_options[:current_user]
  end

  def has_contract
    # Try to determine if we have a contract
    if object.conversationable.present?
      true
    else
      # wasn't a conversationable, see if we have a shortcode
      m = object.messages.first.body
      contract = if m =~ /\[roster id=\"([0-9]+)\"/
        Roster.find_by_id $1
      elsif m =~ /\[contract id=\"([0-9]+)\"/
        Contract.find_by_id $1
      elsif m =~ /\[bounty id=\"([0-9]+)\"/
        Bounty.find_by_id $1
      end
      contract.present?
    end
  end
end
