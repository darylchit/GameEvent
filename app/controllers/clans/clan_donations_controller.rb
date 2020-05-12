class Clans::ClanDonationsController < ApplicationController
  before_filter :authenticate_user!, :except =>[:ipn_notification]
  before_filter :find_clan, only: [ :create ]
  protect_from_forgery :except => [:ipn_notifcation]

  def create
    @clan_donation = ClanDonation.new(clan_donation_params)
    @clan_donation.user = current_user

    if @clan_donation.save
      @pay_response = build_payment_request(@clan_donation)

      unless @pay_response.success?
        @clan_donation.logs.create( log: @pay_response.error.first.message )
        flash[:error] = 'There was a problem submitting your payment. Please have the recipient check their PayPal email address, and try again.'
        return redirect_to request.referer
      end

      @clan_donation.logs.create(log: @pay_response.to_json )
      redirect_to "#{Rails.application.config.adaptive_payments_url}#{@pay_response.payKey}"

    else
      redirect_to @clan
    end
  end

  def thanks
    @clan_donation = current_user.clan_donations.find(params[:id])
    @clan_donation.status = :complete
    @clan_donation.save
    redirect_to @clan_donation.clan, flash: { success: "Your donation has been sent to #{@clan_donation.clan.name}" }
  rescue
    redirect_to root_path, flash: { error: "Sorry, we were not able to find that page." }
  end

  def ipn_notification
    if api.ipn_valid?(request.raw_post) and params[:id]
      @clan_donation = ClanDonation.find(params[:id])
      @clan_donation.logs.create(log: params.to_json)

      if params[:status].eql?("COMPLETED")
        @clan_donation.pay_pal_transaction_id = params[:transaction]["0"][".id"]
        @clan_donation.complete!
      else
        # A response that we do not handle
        @clan_donation.unknown!
      end
    end

    #we just need to return a blank 200 so IPN will stop posting back to us
    render :text => ""
  end

  private

    def find_clan
      @clan = Clan.friendly.find( params[:clan_id] )
    end

    def api
      @api ||= PayPal::SDK::AdaptivePayments::API.new
    end

    def build_payment_request(clan_donation)
      clan = clan_donation.clan
      @pay = api.build_pay({
        :actionType => "PAY",
        :cancelUrl => "#{Rails.application.config.return_host}/clans/#{clan.id}",
        :currencyCode => "USD",
        :feesPayer => "EACHRECEIVER",
        :ipnNotificationUrl => "#{Rails.application.config.ipn_host}#{ipn_notification_clan_clan_donation_path(clan.id, clan_donation.id)}",
        :receiverList => {
          :receiver => [{
            #merc
            :amount => clan_donation.amount_dollars.to_f,
            :email =>  clan.paypal_email.present?  ? clan.paypal_email : clan.host.email
          }]
        },
        :returnUrl => "#{Rails.application.config.return_host}#{thanks_clan_clan_donation_path(clan.id, clan_donation.id)}"
      })

      clan_donation.logs.create( log: @pay.to_json )
      return @api.pay(@pay)
    end

    def clan_donation_params
      params.require(:clan_donation).permit(:amount_dollars, :clan_id)
    end

end
