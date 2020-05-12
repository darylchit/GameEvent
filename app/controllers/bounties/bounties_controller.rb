class Bounties::BountiesController < InheritedResources::Base
  include PayPal::Request
  include PayPal::Ipn
  include SortsAndFilters
  before_filter :authenticate_user!, :except =>[:index, :ipn_notification]

  before_filter :get_collection, only: [:index]
  before_filter :filter_params, only: [:index]
  before_filter  :set_search, only: [:index]
  respond_to :html, :js
  protect_from_forgery :except => [:close_pay_pal, :ipn_notifcation]

  def index
    if params[:select_filter] && !params[:select_filter][:game].nil? && params[:select_filter][:game].count == 1
      @cover_game = Game.where(:id => params[:select_filter][:game].first).last
    end

    #if params[:grid][:f]["games.id"].count == 1
    #@cover_game = select_filter[game]

    @games = GameGameSystemJoin.all

    @sorted_games = Game.all.sort_by &:title
    @sorted_systems = GameSystem.all.sort_by &:title

    @public_events = @resource.page params[:page]

        # convert users.date_of_birth "fr" and "to" to dates

  end

  def create
    redirect_to bounties_path
  end

  def update
    redirect_to bounties_path
  end

  def destroy
    redirect_to bounties_path
  end

  def claim
    @bounty = Bounty.find(params[:bounty_id])
    ggs = GameGameSystemJoin.find params[:bounty][:selected_game_game_system_join_id]

    if !current_user.has_game_system?(ggs.game_system)
      @message = "Sorry, you cannot claim this event as it does not look like you have a compatible game system. You can add a game system by <a href=\"#{edit_profile_path}\">adding an IGN</a> to your Gaming Information for this system.".html_safe
      render 'bounty_error'
    elsif !@bounty.can_be_claimed_by_user?(current_user)
      @message = "Invalid Claim"
      render 'bounty_error'
    elsif resource.status == "Open"
      if params[:bounty].present? and params[:bounty][:selected_game_game_system_join_id].present?
        resource.seller_id = current_user.id
        resource.selected_game_game_system_join_id = params[:bounty][:selected_game_game_system_join_id]
        resource.status = "Claimed"
        resource.claimed_at = Time.now
        resource.save
        flash[:success] = "Event Claimed"

        current_user.send_message(resource.buyer, "I've claimed your event [contract id=\"#{resource.id}\"]", 'Event Claimed', true, nil, Time.now, resource)

        render 'bounty_claimed'
      else
        @message = "Please select a title to play."
        render 'bounty_error'
      end
    else
      @message = "Bounty Already Claimed"
      render 'bounty_error'
    end
  end

  def payment_request
    @bounty = Bounty.find(params[:bounty_id])
    @pay_response = build_payment_request(@bounty)

    if !@pay_response.success?
        #display error
        flash[:error] = 'There was a problem submitting your payment. Please have the mercenary check their PayPal email address, and try again.'
        redirect_to request.referer
      else
        redirect_to "#{Rails.application.config.adaptive_payments_url}#{@pay_response.payKey}"
      end
    end

    def purchase
    #IPN hasn't come through yet (or is happening right now!), we'll mark it as such for right now
    # This controller handles the return url redirect after the user has
    # completed the payment on pay pal. This redirect is NOT confirmation
    # that the purchase has been completed - it's just for UX purposes while
    # we're waiting for Pay Pal to send the IPN notification, which is the
    # real deal as far as confirming the purchase.  That IPN is handled by
    # the IPN concern.
    resource = Bounty.find(params[:bounty_id])
    if resource.status == "Invoiced"
      resource.status = "Pending Payment Confirmation from Paypal"
      resource.save
    else
      redirect_to claimed_bounties_path
    end
  end

  def close_pay_pal
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def feed
    bounties = eligible_bounties.where('"contracts"."created_at" > ?', params[:since])
    @number_new = bounties.size
  end

  def check_site_password
    # do nothing
  end

  private
  def permitted_params
    params.permit(bounty: [:selected_game_game_system_join_id])
  end

  def get_collection 
    # moved logic to Roster class method to allow it to be shared with the dashboard and other controllers
    if current_user.present?
      @resource = Roster.eligible_bounties(current_user).where("clan_id IS ?", nil)#.includes(:users, :contract_game_game_system_joins)
    else
      @resource = Roster.where("clan_id IS ?", nil)
    end  
  end

end
