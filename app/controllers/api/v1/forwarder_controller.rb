class Api::V1::ForwarderController < Api::V1::BaseController
  respond_to :html

  # Forwards an app user to a page after signing them in
  #
  # @param [String] email user's email address
  # @param [String] token user's authentication token
  # @param [String] n the next URL to forward the user to
  def forward
    if params[:email].present? && params[:token].present? && params[:n].present?
      users = User.where(:authentication_token => params[:token]).where(:email => params[:email])
      if users.present? && users.count == 1
        sign_in(:user, users.first, { :bypass => true })
  			redirect_to params[:n]
  		else
      	redirect_to '/'
  		end
    else
      redirect_to '/'
    end
  end
end
