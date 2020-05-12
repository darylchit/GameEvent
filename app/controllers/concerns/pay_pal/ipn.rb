module PayPal::Ipn
	extend ActiveSupport::Concern

	#IPN action
	def ipn_notification
		
		#the sdk is nice enough to handle the authentication of the transaction
		#for us.
		if api.ipn_valid?(request.raw_post)
			if(params[:contract_type] == 'Bounty')
				contract = Bounty.find(params[:bounty_id])
			else
				contract = Contract.find(params[:contract_id])
			end
			ContractPaypalLog.create(contract_id: contract.id, log: params.to_json)

			contract.buyer_id = params[:buyer_id]
			contract.pay_pal_transaction_id = params[:transaction]["0"][".id"]
			contract.status = "Payment Complete"
			contract.save
		end
		#we just need to return a blank 200 so IPN will stop posting back to us
		render :text => ""
	end

	private
		def api
			@api ||= PayPal::SDK::AdaptivePayments::API.new
		end
end
