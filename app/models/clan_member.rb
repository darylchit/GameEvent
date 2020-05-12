class ClanMember < ActiveRecord::Base
	#soft delete
	acts_as_paranoid

	belongs_to :clan
	belongs_to :user
	belongs_to :clan_rank
  after_create :remove_invites
	after_create :set_default_rank
	after_create :create_callback_delay
	after_destroy :remove_chat_receipt


  def can_perform? action
    # Host can always perform any action, duh
    return true if clan.host == user
    # clan_rank.permissions?(action.to_sym)
  end


    def create_callback_delay
      ClanMember.delay.send_join_notice(id)
    end

    def self.send_join_notice(id)
      clan_member = ClanMember.find_by_id(id)
      if clan_member.present?
        clan_member.add_chat_receipt
      end
    end

	  def add_chat_receipt
			message = message = Message.find_by_message_type_and_body_and_notified_object_id('clan_messages', 'clan_chat', clan_id)
			if message.present?
				user.receipts.find_or_create_by(message: message, message_type: message.message_type)
				clan_message = user.clan_messages.create(message: "#{user.username} Joined #{clan.name}", clan_id: clan_id)
				message.receipts.update_all(created_at: Time.now)
	       message.receipts.each do|receipt|
	         receipt.update_attributes(deleted_at: nil, is_read: false) if receipt.receiver.id != user.id
	         receipt.update_attributes(deleted_at: nil, is_read: true) if receipt.receiver.id == user.id
	       end
	      clan_message.send_app_notification
			end
    end

    private
		def remove_chat_receipt
			message = message = Message.find_by_message_type_and_body_and_notified_object_id('clan_messages', 'clan_chat', clan_id)
			if message.present?
				receipt = user.receipts.find_by(message: message, message_type: message.message_type)
				receipt.really_delete if receipt.present?
			end
		end
    def remove_invites
      ClanInvite.where(user_id: self.user_id, clan_id: self.clan_id).each do |invite|
        invite.destroy
        # invite.clan.host.mailbox.notifications if Rails.env != "test"
      end
      if Rails.env != "test"
        # subj = "#{user.username} has joined clan #{clan.name}"
        # body = "#{user.username} has joined clan #{clan.name}"
        # clan.host.notify(subj, body, self)
      end
    end

		def set_default_rank
			if clan.clan_ranks.present?
				update_attributes(clan_rank_id: clan.clan_ranks.where(is_default: true).first.id)
			end
		end

end
