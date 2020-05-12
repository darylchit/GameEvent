class ReceiptsController < ApplicationController
	before_filter :authenticate_user!
	respond_to :html, :js

	expose :receipt, scope: ->{ Receipt.with_deleted }

	def destroy
		receipt = Receipt.find(params[:id])
		receipt.destroy
	end

	def destroy_receipts
		ids = params[:receipts_ids]
		if ids.present?
		  ids.each do |id|
			  Receipt.find(id).destroy
		  end
		end
	end

	def mark_read
		ids = params[:receipts_ids]
		if ids.present?
			ids.each do |id|
				Receipt.find(id).update_attributes(is_read: true)
			end
		end
	end

	def site_notice
		if receipt.present? && !receipt.is_read?
			receipt.is_read = true
			receipt.save
		end
	end

end
