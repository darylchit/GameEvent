class Api::V2::ReceiptsController < ApplicationController
  respond_to :json

  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User

  expose(:receipt) { current_user.receipts.includes(:message).find_by_id(params[:id]) }

  def trash
    @deleted_receipts = []
    if params[:receipts].present? && params[:receipts].is_a?(Hash)
      params[:receipts].values.each do |receipt_id|
         receipt = current_user.receipts.find_by_id(receipt_id)
         if receipt.present?
           receipt.destroy
           @deleted_receipts << receipt.id
         end
      end
    end
  end

  def read
    @read_receipts = []
    if params[:receipts].present? && params[:receipts].is_a?(Hash)
      params[:receipts].values.each do |receipt_id|
         receipt = current_user.receipts.find_by_id(receipt_id)
         if receipt.present?
           if receipt.update_attributes(is_read: true)
             @read_receipts << receipt.id
           end
         end
      end
    end
  end

end
