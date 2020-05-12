class SystemNoticesController < ApplicationController
  before_action :authenticate_admin!, only: [:new, :edit, :delete]

  def index
    @notices = SystemNotice.current
    @header = 'SYSTEM NOTICES'
    render 'shared/_notice_index'
  end

  def new
    @is_clan = false
    @notice = :system_notice
    render 'shared/_notice_form'
  end

  def create
    @new_notice = SystemNotice.new(allowed_params)
    @new_notice.assign_attributes(admin_id: current_admin.id)
    if @new_notice.save
      flash[:success] = 'You have successfully posted a new notice.'
      redirect_to system_notice_path(@new_notice)
    else
      flash[:error] = @new_notice.errors.full_messages
      redirect_to new_system_notice_path
    end
  end

  def show
    @notice = SystemNotice.find(params[:id])
    @header = 'SYSTEM NOTICE'
    @is_clan = false
    render 'shared/_notice_show'
  end

  def destroy
    @notice = SystemNotice.find(params[:id])
    if @notice.destroy
      flash[:success] = 'Notice has been deleted.'
    else
      flash[:error] = 'Notice was not able to be deleted.'
    end
    render 'shared/_notice_delete'
  end

  private

  def allowed_params
    params.require(:system_notice).permit(:title, :body, :expiration, :user_id, :admin_id)
  end
end
