class MessagesController < ApplicationController
	include MessagesHelper
	include UserPreferences
	include MessageQuery
	before_filter :authenticate_user!
	before_filter :update_preferences_params, only: [:preferences]
	before_filter :get_favorite_users
  expose :my_clans, :build_my_clans
  expose :message
	expose :message_replies do
		if message.message_type == 'clan_messages' && message.body == 'clan_chat'
			message.notified_object.clan_messages
		else
		  message.replies
	 	end
	end
	# expose :user_messages, :build_messages
	# expose :invitations, :build_event_invitations
	# expose :notices, :build_event_notices
	# expose :public_games, :build_public_game_alerts
	# expose :clan_receipts, :build_clan_messages
	expose :deleted, :build_recently_deleted
  expose :user_receiver, :build_receiver

	expose :receipts do
    ids = []
    ids = ids + build_messages.ids if build_messages.present?
    ids = ids + build_clan_messages.ids if build_clan_messages.present?
    ids = ids + build_event_invitations.ids if build_event_invitations.present?
    ids = ids + build_event_notices.ids if build_event_notices.present?
    current_user.receipts.where('receipts.id in (?)', ids).includes(:message).order('created_at desc')
  end

	respond_to :html, :js

	def index
		@box_type = 'Inbox'
  end

  def clan_messages
    @box_type = 'Clan Messages'
  end

	def event_invitations
		@box_type = 'Event Invitations'
	end

	def event_notices
		@box_type = 'Roster Notices'
	end

	def public_game_alerts
		@box_type = 'Public Game Alerts'
	end

	def recently_deleted
		@box_type = 'Recently Deleted'
	end

  def reply_to
    respond_to do |format |
      format.js
      format.html{ redirect_to messages_path}
    end
  end

  def reply
    @reply = current_user.replies.new(reply_params)
    if @reply.save
			@reply.message.receipts.update_all(created_at: Time.now)
      @reply.message.receipts.each do|receipt|
        receipt.update_attributes(deleted_at: nil, is_read: false) if receipt.receiver.id != current_user.id
        receipt.update_attributes(deleted_at: nil, is_read: true) if receipt.receiver.id == current_user.id
      end
			@reply.send_app_notification
			sync_new @reply
    end
  end

	def replies
		receipt =  message.receipts.with_deleted.find_by_receiver_id(current_user.id)
		if receipt.present? && !receipt.is_read?
			receipt.is_read = true
			receipt.save
		end
	end

	def notifications
		@box = current_user.mailbox.notifications.limit(100)
		@box_type = "Notifications"
		@box.each do |notification|
			begin
				if notification.notified_object_type == "ClanInvite"
					ClanInvite.find(notification.notified_object_id)
				end
			rescue
			 	notification.destroy
			end
		end
		@box = current_user.mailbox.notifications.limit(25)
		render 'messages/index'
	end

	def trash
		@box = current_user.mailbox.trash
		@box_type = 'Trash'
		render 'index'
	end

	def settings
		@box_type = 'Settings'
	end

	def show
		@conversation = current_user.mailbox.conversations.find(params[:id])
		@box_type = @conversation.is_completely_trashed?(current_user) ? 'trash' : 'messages'
		@conversation.mark_as_read(current_user)

		# figure out who this is with
		@other_user = current_user
		@conversation.participants.each do |p|
			if p != current_user
				@other_user = p
			end
		end

		@origin = @conversation.originator

		if @origin != current_user
			@other_participants = @conversation.participants.uniq{|x| x.id}.delete_if {|obj| obj == @origin || obj == @current_user}
		else
			if @origin != @conversation.participants.uniq{|x| x.id}.first
				@first_recipient = @conversation.participants.first
				@other_participants = @conversation.participants.uniq{|x| x.id}.delete_if {|obj| obj == @origin }
			else
				@first_recipient = @conversation.participants[1]
				@other_participants = @conversation.participants.uniq{|x| x.id}.drop(1)
			end
		end

	end

	def new
		recipient = User.find params[:recipient_id]
		if recipient.is_blocking_user?(current_user) or current_user.is_blocking_user?(recipient)
			redirect_to profile_path
		end
		respond_to do |format |
			format.js
			format.html { redirect_to :back }
		end
	end

	def destroy
		destroy_message!
		redirect_to messages_path
	end


	def create
		if can_communicate_with_recipient?
			send_user_message!
			@bloked = false
		else
			@bloked = true
		end

		respond_to do | format |
			format.js
		end
	end

	protected

  def can_communicate_with_recipient?
    can_communicate = true
    if user_receiver.present?
      can_communicate = false if user_receiver.is_blocking_user?(current_user) or current_user.is_blocking_user?(user_receiver)
    end
    can_communicate
  end

  def send_user_message!
    if user_receiver.present?
      message = current_user.messages.create(message_type: :user_messages, subject: params[:message])
      current_user.receipts.create(message: message, message_type: message.message_type, is_read: true)
      user_receiver.receipts.create(message: message, message_type: message.message_type)
			reply = current_user.replies.create(message: message, subject: message.subject)
			reply.send_app_notification
    end
  end

  def resource
    current_user
  end

=begin
	def can_communicate_with_recipient?
		# figure out who this is with
		if params[:recipient_id].present?
			if params[:recipient_id].class == Array
				recipients = User.where :id => params[:recipient_id]
			else
				recipients = [User.find(params[:recipient_id])]
			end
		else
			conversation = current_user.mailbox.conversations.find(params[:conversation_id])
			recipients = []
			conversation.participants.each do |p|
				if p != current_user
					recipients << p
				end
			end
		end

		can_communicate = true
		recipients.each do | r |
			can_communicate = false if r.is_blocking_user?(current_user) or current_user.is_blocking_user?(r)
		end

		can_communicate
	end


	# Sends the message using the parameters on the request. Also sets `@conversation` and `@receipt`
	def send_message!
		if params[:conversation_id].present?
			@conversation = current_user.mailbox.conversations.find(params[:conversation_id])
		else
			@conversation = nil
		end
		if @conversation.present?
			@receipt = current_user.reply_to_conversation(@conversation, params[:message], "Reply From #{current_user.username}")
			begin
				NotificationWorker.perform_async(@receipt.message.id, 'Mailboxer::Message', 'Notifications::MessageNotification', 'conversation_reply') if @receipt.errors.blank?
			rescue => e
				puts e
			end
		else
			if params[:recipient_id].present?
				@recipient = User.find(params[:recipient_id])
			else
				#dunno why you'd wanna do this, but ok.
				@recipient = current_user
			end

			@receipt = current_user.send_message( (@recipient.class == Array ? @recipient : [@recipient]) , params[:message], "Message From #{current_user.username}")
			begin
				NotificationWorker.perform_async(@receipt.message.id, 'Mailboxer::Message', 'Notifications::MessageNotification', 'new_conversation') if @receipt.errors.blank?
			rescue => e
				puts e
			end
		end
	end
=end

	# Trashes the conversation using the parameters passed in the request.
	def destroy_message!
			@conversation = current_user.mailbox.conversations.find(params[:id])

			if @conversation.present?
				if @conversation.is_trashed?(current_user)
					@conversation.untrash(current_user)
				else
					@conversation.move_to_trash(current_user)
				end

			end
	end

	private


  def reply_params
    params.require(:reply).permit( :subject, :message_id)
  end

  def build_my_clans
    current_user.clans.order(:name)
  end

	def build_public_game_alerts
		# current_user.receipts.includes(:message)
	end

  def build_receiver
    User.find(params[:recipient_id])
  end

  def get_favorite_users
		@favorites_user = current_user.favorites.collect{|u| [u.favorited_user.username, u.favorited_user.id] }
  end



end
