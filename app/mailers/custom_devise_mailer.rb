class CustomDeviseMailer < Devise::Mailer

  before_filter :add_inline_attachment!

  def confirmation_instructions(record, token, opts={})
    super
  end

  def reset_password_instructions(record, token, opts={})
    super
  end

  def unlock_instructions(record, token, opts={})
    super
  end

  def email_changed(record, opts={})
    super
  end

  def password_change(record, opts={})
    super
  end

  protected

  def subject_for(key)
    if key.to_s == 'confirmation_instructions'
      "Game Roster - Email Confirmation Instructions"
    elsif key.to_s == 'reset_password_instructions'
      "Game Roster - Password Reset Instructions"
    else
      return super
    end
  end

  private
  def add_inline_attachment!
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
  end
end
