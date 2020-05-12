class MailboxerMailer < Mailboxer::MessageMailer
  add_template_helper MessagesHelper
  prepend_view_path 'views/mailboxer'

  def send_email(message, receiver)
    super(message, receiver)
  end

  def new_message_email(message, receiver)
    super(message, receiver)
  end

  def reply_message_email(message, receiver)
    super(message, receiver)
  end

end
