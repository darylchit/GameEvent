class Admin::BlogsController < ApplicationController
  before_filter :authenticate_admin!

  expose :blog
  expose :blogs
  expose :blogs_grid, :build_blogs_grid

  def create
    if blog.save
      redirect_to edit_admin_blog_path(blog)
      flash[:notice] = 'Notice Created'
    else
      flash[:notice] = 'Error'
      render :new
    end
  end

  def update
    if blog.update(blog_params)
      flash[:notice] = 'Notice Updated'
      redirect_to edit_admin_blog_path(blog)
    else
      flash[:notice] = 'Error'
      render :edit
    end
  end

  def test_mail
    user = User.find_by_email('gameroster.us@gmail.com')
    ApplicationMailer.blog_mail(user, blog).deliver_now
    message = blog.messages.find_or_create_by(message_type: 'site_notice')
    user.receipts.create(message: message, message_type: message.message_type)
    if Rails.env.production?
      t_user = User.find_by_email('admin@gameroster.com')
      t_user.receipts.create(message: message, message_type: message.message_type)
      ApplicationMailer.blog_mail(t_user, blog).deliver_now
    end
    flash[:notice] = 'Mail Sent'
    redirect_to edit_admin_blog_path(blog)
  end

  def publish
    if blog.publish!
      flash[:notice] = 'Notice Published'
    else
      flash[:notice] = 'Error'
    end
    redirect_to edit_admin_blog_path(blog)
  end

  private

  def blog_params
    permited_params = [:title, :value, :value2, :is_blog, :blog_type]
    params.require(:blog).permit( permited_params)
  end

  def build_blogs_grid
    initialize_grid(Blog.all)
  end

end
