module MessagesHelper

  def get_user_message_receiver(message)
   begin
      if message.is_a?(Message) && message.message_type == 'user_messages'
        message.receipts.with_deleted.where.not(receiver_id:  message.sender.id).take.receiver  
      end
    rescue =>e
       raise 'UserMessages : Receiver Not avilable'
    end  
  end

  def parse_message(message, user, email=false)
    raw Shortcode.process(message, {current_user: user, email: email})
  end

  def get_recipient(conversation)
  	n_others = conversation.recipients.reject{|u| u.id == current_user.id }
  	if n_others.present?
       n_others.first
    else
    	current_user
    end
  end

end
