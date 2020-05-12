class DonationsController < InheritedResources::Base


	before_filter :authenticate_user!, :except =>[:ipn_notification]
  before_filter :find_donatee, only: [ :new, :create ]
	protect_from_forgery :except => [:ipn_notifcation]

  def new
    @donation = build_resource
    @donation.donatee = @donatee
    respond_to do |format|
      format.js
    end
  end

  def create
    @donation = build_resource
    @donation.donatee = @donatee
    if @donation.save
		  @pay_response = build_payment_request(@donation)
      unless @pay_response.success?
        @donation.logs.create( log: @pay_response.error.first.message )
			  flash[:error] = 'There was a problem submitting your payment. Please have the recipient check their PayPal email address, and try again.'
			  return redirect_to request.referer
      end
      @donation.logs.create(log: @pay_response.to_json )
			redirect_to "#{Rails.application.config.adaptive_payments_url}#{@pay_response.payKey}"
    else
      flash[:error] = 'There was a problem submitting your payment. Please have the recipient check their PayPal email address, and try again.'
      return redirect_to request.referer
    end
  end

  def thanks
    @donation = current_user.donations.find(params[:id])
    @donation.status = :complete
    @donation.save
    redirect_to root_path, flash: { success: "Your donation has been sent to #{@donation.donatee.username}" }
  rescue 
    redirect_to root_path, flash: { error: "Sorry, we were not able to find that page." }
  end

  def ipn_notification
		if api.ipn_valid?(request.raw_post) and params[:id]
			@donation = Donation.find(params[:id])
			@donation.logs.create(log: params.to_json)

      if params[:status].eql?("COMPLETED")
        @donation.pay_pal_transaction_id = params[:transaction]["0"][".id"]
        @donation.complete!
      else
        # A response that we do not handle
        @donation.unknown!
      end
		end

		#we just need to return a blank 200 so IPN will stop posting back to us
		render :text => ""
	end

  private

    def donation_params
      params.require(:donation).permit(:amount_dollars)
    end

    def find_donatee
      @donatee = User.find_by_username( params[:profile_id] )
    end

    def begin_of_association_chain
      @current_user
    end

		def api
			@api ||= PayPal::SDK::AdaptivePayments::API.new
		end

    def build_payment_request(donation)
      donatee = donation.donatee
      @pay = api.build_pay({
        :actionType => "PAY",
        :cancelUrl => "#{Rails.application.config.return_host}/profiles/#{donatee.username}",
        :currencyCode => "USD",
        :feesPayer => "EACHRECEIVER",
        :ipnNotificationUrl => "#{Rails.application.config.ipn_host}#{ipn_notification_donation_path(donation)}",
        :receiverList => {
          :receiver => [{
            #merc
            :amount => donation.amount_dollars.to_f,
            :email =>  donatee.paypal_email.present?  ? donatee.paypal_email : donatee.email
          }]
        },
        :returnUrl => "#{Rails.application.config.return_host}#{thanks_donation_path(donation)}" 
      })

      donation.logs.create( log: @pay.to_json )
      return @api.pay(@pay)
    end
	end

