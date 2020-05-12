class Api::V2::Clans::ClanApplicationsController < ApplicationController
  respond_to :json

  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User
  expose(:clan) { Clan.with_deleted.find_by_id(params[:clan_id]) }
  expose(:clan_application) { clan.clan_applications.with_deleted.find_by_id(params[:clan_application_id]) }

  def accept
    if clan.present? && clan_application.present? && clan_application.reviewer.nil?
      clan.clan_members.find_or_create_by(user_id: clan_application.user_id)
      clan_application.update_attributes(reviewer_id: current_user.id, reviewed_at: Time.now, status: true)
      subj = "Clan Application Status Update"
      body = "#{clan.name.upcase} Has Accepted Your Application"
      message = clan_application.messages.create(message_type: 'clan_applications', subject: subj, body: body)
      clan_application.user.receipts.create(message: message, message_type: message.message_type)
      clan_application.update_attributes(deleted_at: Time.now)
      clan_application.reload
    end
  end

  def reject
    if clan.present? && clan_application.present? && clan_application.reviewer.nil?
      clan_application.update_attributes(reviewer_id: current_user.id, reviewed_at: Time.now, status: false)
      subj = "Clan Application Status Update"
      body = "#{clan.name.upcase} Has Rejected Your Application"
      message = clan_application.messages.create(message_type: 'clan_applications', subject: subj, body: body)
      clan_application.user.receipts.create(message: message, message_type: message.message_type)
      clan_application.update_attributes(deleted_at: Time.now)
      clan_application.reload
    end

  end

end
