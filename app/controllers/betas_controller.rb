class BetasController < ApplicationController

  def create
    if params[:password] == 'phoenix'
      session[:betacode] = params[:password]
      redirect_to root_path
    else
      flash[:alert] = 'Please Enter Valid Beta code.'
      redirect_to new_beta_path
    end
  end

  def index
    redirect_to root_path
  end

  def unsubscribe
    user = User.find(params[:id])
    if user.present?
      user.update_attributes(notif_email: false)
      flash[:notice] = 'You are unsubscribed'
    end
    redirect_to root_path
  end
end
