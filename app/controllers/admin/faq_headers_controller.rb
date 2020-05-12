class Admin::FaqHeadersController < ApplicationController
  before_filter :authenticate_admin!

  expose :faq_header
  expose :faq_headers
  expose :faq_header_grid, :build_grid
  expose :faq_grid, :build_faq_grid
  expose :active_faq_headers, :build_active_faq_header

  def create
    if faq_header.save
      redirect_to admin_faq_headers_path
    else
      render :new
    end
  end

  def update
    if faq_header.update(faq_header_params)
      redirect_to admin_faq_headers_path
    else
      render :edit
    end
  end

  private

  def faq_header_params
    permited_params = [:name, :rank, :active]
    params.require(:faq_header).permit( permited_params)
  end

  def build_faq_grid
    initialize_grid(faq_header.faqs.order(:rank))
  end

  def build_grid
    initialize_grid(FaqHeader.all.order(:rank))
  end

  def build_active_faq_header
    FaqHeader.live
  end

end
