class Admin::FaqsController < ApplicationController
  before_filter :authenticate_admin!
  expose :faq_header
  expose :faqs, scope: ->{ faq_header.faqs }
  expose :faq, scope: ->{ faq_header.faqs }

  def create
    faq.faq_header = faq_header
    if faq.save
      redirect_to admin_faq_header_path(faq_header)
    else
      render :new
    end
  end

  def update
    if faq.update(faq_params)
      redirect_to admin_faq_header_path(faq_header)
    else
      render :edit
    end
  end


  private

  def faq_params
    permited_params = [:name, :rank, :active, :answer]
    params.require(:faq).permit( permited_params)
  end



end
