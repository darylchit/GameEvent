 class Api::V2::Messages::RepliesController < ApplicationController
   respond_to :json

   protect_from_forgery with: :null_session
   acts_as_token_authentication_handler_for User

   expose :reply,  scope: ->{ current_user.replies }

   def create
     if reply.message.message_type = 'clan_messages' && reply.message.body == 'clan_chat'
       message = reply.message
       clan = message.notified_object
       @clan_message = current_user.clan_messages.new(message: reply.subject, clan_id: clan.id)
       if @clan_message.save
         message.receipts.update_all(created_at: Time.now)
          message.receipts.each do|receipt|
            receipt.update_attributes(deleted_at: nil, is_read: false) if receipt.receiver.id != current_user.id
            receipt.update_attributes(deleted_at: nil, is_read: true) if receipt.receiver.id == current_user.id
          end
         sync_new @clan_message
         @clan_message.send_app_notification
       end
     else
       if reply.save
   			reply.message.receipts.update_all(created_at: Time.now)
         reply.message.receipts.each do|receipt|
           receipt.update_attributes(deleted_at: nil, is_read: false) if receipt.receiver.id != current_user.id
           receipt.update_attributes(deleted_at: nil, is_read: true) if receipt.receiver.id == current_user.id
         end
         reply.send_app_notification
       end
     end
   end


   private

   def reply_params
     params.require(:reply).permit( :subject, :message_id)
   end

 end
