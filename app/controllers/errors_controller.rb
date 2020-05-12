class ErrorsController < ApplicationController
  layout 'application'
  include Rails.application.routes.url_helpers

  def error404
    @pagetitle = "Page Not Found"
    render 'error404', status: :not_found
  end

  def show
    if status_code != '404'
      @pagetitle = 'Something Went Wrong'
      render 'error500', status: :something_went_wrong
    else
      error404
    end
  end

  protected
    def status_code
      params[:code] || '500'
    end
end
