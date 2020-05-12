module PayPal::Request
	extend ActiveSupport::Concern
	
	def build_payment_request(contract)
		contract_type = contract.contract_type.downcase
		contract_type_plural = contract_type.pluralize
		@pay = api.build_pay({
			:actionType => "PAY",
			:cancelUrl => "#{Rails.application.config.return_host}/my-posted-events",
			:currencyCode => "USD",
			:feesPayer => "EACHRECEIVER",
			:ipnNotificationUrl => "#{Rails.application.config.ipn_host}/#{contract_type_plural}/#{contract.id}/ipn_notification?buyer_id=#{current_user.id}&contract_type=#{contract.contract_type}",
			:receiverList => {
				:receiver => [{
					#merc
					:amount => contract.price_in_dollars.to_f,
					:email =>  contract.seller.paypal_email.present?  ? contract.seller.paypal_email : contract.seller.email
				}]
			},
      :returnUrl => "#{Rails.application.config.return_host}/#{contract_type_plural}/#{contract.id}/purchase" 
		})
		
		ContractPaypalLog.create(
			contract_id: params["#{contract_type}_id"], 
			log: @pay.to_json
		)
		return @api.pay(@pay)
	end
	
	private
		def api
			@api ||= PayPal::SDK::AdaptivePayments::API.new
		end
end
