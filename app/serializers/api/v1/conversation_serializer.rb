class Api::V1::ConversationSerializer < ActiveModel::Serializer
  attributes :id, :messages, :contract

  def messages
    object.messages.order(:created_at).map{|m| Api::V1::MessageSerializer.new m, root: false}
  end

  def body
    object.body.gsub(/\[[^\]]*\]/, '')
  end

  def contract
    # Try to determine if we have a contract
    if object.conversationable.present?
      Api::V1::ContractSerializer.new object.conversationable, root: false
    else
      # wasn't a conversationable, see if we have a shortcode
      m = object.messages.first.body
      contract = if m =~ /\[roster id=\"([0-9]+)\"/
        Roster.find_by_id $1
      elsif m =~ /\[contract id=\"([0-9]+)\"/
        Contract.find_by_id $1
      elsif m =~ /\[bounty id=\"([0-9]+)\"/
        Bounty.find_by_id $1
      end
      if contract.present?
        Api::V1::ContractSerializer.new contract, root: false
      end
    end
  end
end
