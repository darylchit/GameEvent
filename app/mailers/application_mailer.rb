class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  helper :profile

  def send_welcome_email(user)
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
    mail(to: user.email,
      subject: AdminConfig.user_create_subject.value.html_safe,
      template_path: 'users/mailer',
      template_name: 'welcome'
    )
  end

  def send_clan_welcome_email user
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
    mail(to: user.email,
      subject: AdminConfig.clan_create_subject.value.html_safe,
      template_path: 'users/mailer',
      template_name: 'clan'
    )
  end

  def blog_mail user, blog
    @blog = blog
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
    mail( to: user.email, subject: blog.title )
  end


  def send_donation_email(event)

    # event can be a Bounty or a Contract
    @event    = event
    @donor    = event.buyer
    @donatee  = event.seller

    mail( to: @donor.email, subject: "Donation For #{@donatee.username}")
  end

  def send_public_game_announcement user, roster
    @user   = user
    @roster = roster
    Time.use_zone( user.timezone) do
      mail( to: @user.email, subject: "New Public Game. Starting at %s" % [ @roster.start_date_time.in_time_zone.strftime("%m/%d %l:%M%p %Z") ] )
    end
  end

  def send_reminder_email user, gamejoin, roster
    @user   = user
    @gamejoin = gamejoin
    @roster = roster
    Time.use_zone( user.timezone) do
      mail( to: @user.email, subject: "You have an upcoming event | %s (%s) | %s" % [ gamejoin.game.title, gamejoin.game_system.abbreviation, @roster.start_date_time.in_time_zone.strftime("%m/%d %l:%M%p %Z") ] )
    end
  end

  def send_beta_email user
    @user = user
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
    mail( to: user.email, subject: 'Game Roster Open Beta & Elite Promotion')
  end

  def discord_mail user
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
    mail( to: user.email, subject: "It's Alive...Clan Discord LFG Bot Now Online")
  end

  def discord_bot_command_email user
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
    mail( to: user.email, subject: "Discord Bot Updates")
  end

  def twitch_info clan
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
    mail( to: clan.host.email, subject: "Check Out The New Twitch LFG")
  end

  def promotion_expiration subscription
    @user = subscription.user
    @subscription = subscription
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
    mail( to: @user.email, subject: 'Game Roster Promotion Expiration')
  end

  def clan_setup_tips clan
    if clan.is_a?(Clan)
      attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo-email.png")
      mail( to: clan.host.email, subject: 'Clan Tips and FAQ')
    end
  end

end
