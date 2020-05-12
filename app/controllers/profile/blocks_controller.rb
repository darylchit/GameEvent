class Profile::BlocksController < InheritedResources::Base
  defaults :resource_class => Block
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @blocked_user = User.find params[:blocked_user_id]

    # sanity check
    is_error = !is_valid_block(@blocked_user)

    if is_error
      render text: ''
      return
    end

    @block = Block.new
    @block.blocked_user = @blocked_user
    super
  end

  def create
    @blocked_user = User.find params[:block][:blocked_user_id]
    # sanity check
    is_error = !is_valid_block(@blocked_user)

    if is_error
      render text: ''
      return
    end

    create!(:notice => "#{@blocked_user.username} has been blocked"){ redirect_path }
  end

  def destroy
    @block_id = resource.id
    username = resource.blocked_user.username
    destroy! do |format|
      format.html do
        flash[:notice] = "#{username} has been unblocked"
        path = redirect_path
        if is_mobile_app? && path.index('v=blocks').nil?
          path += '?v=blocks'
        end
        redirect_to path
      end
      @total_blocked = current_user.blocks.count
      format.js{}
    end
  end

  private
  def permitted_params
    params.permit(:blocked_user_id, :contract_id, block: [:blocked_user_id, :contract_id])
  end

  protected
  def begin_of_association_chain
    current_user
  end

  def is_valid_block(blocked_user)
    current_user != blocked_user
  end

  def redirect_path
    request.referer
  end

  def blocks_and_feedback_path
    profiles_path + '/' + current_user.username + '/blocks-and-feedback'
  end

  def feedback_path
    profiles_path + '/' + current_user.username + '/feedback'
  end
end
