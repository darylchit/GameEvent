class Api::V1::MessagesController < MessagesController
  respond_to :json
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
  protect_from_forgery with: :null_session

  # Gets a list of the current user's messages asdf asdf
  # GET /api/v1/messages
  #
  # @return [Array<Hash>]
  #   * id **(Int)**
  #   * last_message_at **(DateTime)**
  #   * recipients **(Array<String>)**
  #   * snippet **(String)**
  #   * unread **(Boolean)**
  def index
    conversations = current_user.mailbox.conversations(:mailbox_type => 'not_trash')
    respond_with conversations, each_serializer: Api::V1::CompactConversationSerializer, :current_user => current_user, :root => 'conversations'
  end

  # Shows the details of a conversation
  # GET /api/v1/messages/:id
  #
  # @return [Hash]
  #   * id **(Int)**
  #   * messages **(Array<Message>)**
  #       * id **(Int)**
  #       * body **(String)**
  #       * sender **({User})**
  #   * contract **({Contract})**
  def show
    super
    respond_with @conversation, serializer: Api::V1::ConversationSerializer, :current_user => current_user
  end

  # Creates a new conversation, or replies to an existing one
  # POST /api/v1/messages
  #
  # @param conversation_id [Int] if replying to a conversation, this must be set
  # @param recipient_id [Int] if creating a new message, this must be set
  # @param message [String] the body of the message (required)
  # @return [Hash]
  #   * id **(Int)**
  #   * messages **(Array<Message>)**
  #       * id **(Int)**
  #       * body **(String)**
  #       * sender **({User})**
  #   * contract **({Contract})**
  def create
		if !can_communicate_with_recipient?
			render json: { :message => 'You cannot send messages to this user' }, :status => :forbidden
			return
		end

    if params[:message].empty?
			render json: { :message => 'The message cannot be blank' }, :status => :unprocessable_entity
			return
    end

		send_message!

		if @receipt.errors.blank?
      # for some reason, respond_with isn't working here
      render json: Api::V1::ConversationSerializer.new(@receipt.conversation, :current_user => current_user)
		else
			render json: { :message => 'Unable to send your message' }, :status => :unprocessable_entity
		end
	end

  def destroy
    destroy_message!
    render json: { :message => 'Conversation moved to trash' }, :status => :ok
  end

end
