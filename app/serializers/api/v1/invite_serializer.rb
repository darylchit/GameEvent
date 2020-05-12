class Api::V1::InviteSerializer < ActiveModel::Serializer
  attributes :id, :contract, :created_at

  def contract
    # this *really* should only be a roster, but hey just in case
    c = if object.contract.roster?
      Roster.find object.contract.id
    elsif object.contract.bounty?
      Bounty.find object.contract.id
    else
      object.contract
    end
    Api::V1::ContractSerializer.new c, root: false
  end
end
