class Admin::AdminConfigsController < ApplicationController
  before_filter :authenticate_admin!

  expose :mail_signature do
    AdminConfig.mail_signature
  end

  expose :user_create_email do
    AdminConfig.user_create_email
  end

  expose :clan_create_email do
    AdminConfig.clan_create_email
  end

  expose :email_image_css do
    AdminConfig.email_image_css
  end

  expose :email_image_width do
    AdminConfig.email_image_width
  end

  expose :user_create_subject do
    AdminConfig.user_create_subject
  end

  expose :clan_create_subject do
    AdminConfig.clan_create_subject
  end

  expose :admin_config

  def update
    if admin_config.update(admin_config_params)
      redirect_to admin_admin_configs_path
      flash[:notice] = 'Changes Updated'
    else
      render :index
    end
  end

  def user_welcome_mail
    user = User.find_by_email('gameroster.us@gmail.com')
    ApplicationMailer.send_welcome_email(user).deliver_now

    message = AdminConfig.user_create_email.messages.create(message_type: 'site_notice')
    user.receipts.create(message: message, message_type: message.message_type)

    if Rails.env.production?
      t_user = User.find_by_email('admin@gameroster.com')
      ApplicationMailer.send_welcome_email(t_user).deliver_now

      t_user.receipts.create(message: message, message_type: message.message_type)
    end
    flash[:notice] = 'Mail Sent'
    redirect_to admin_admin_configs_path
  end

  def clan_welcome_mail
    user = User.find_by_email('gameroster.us@gmail.com')
    ApplicationMailer.send_clan_welcome_email(user).deliver_now

    message = AdminConfig.clan_create_email.messages.create(message_type: 'site_notice')
    user.receipts.create(message: message, message_type: message.message_type)
    if Rails.env.production?
      t_user = User.find_by_email('admin@gameroster.com')
      ApplicationMailer.send_clan_welcome_email(t_user).deliver_now
      t_user.receipts.create(message: message, message_type: message.message_type)
    end
    flash[:notice] = 'Mail Sent'
    redirect_to admin_admin_configs_path
  end

  private

  def admin_config_params
    permited_params = [:value, :value2]
    params.require(:admin_config).permit( permited_params)
  end

end
