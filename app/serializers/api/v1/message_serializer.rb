class Api::V1::MessageSerializer < ActiveModel::Serializer
  attributes :id, :body, :sender, :created_at

  def sender
    unless object.sender.nil? || object.sender.deleted_account
      Api::V1::UserSerializer.new object.sender, root: false
    else
      { username: '[deleted]', deleted_account: true }
    end
  end

  def body
    object.body.gsub(/\[[^\]]*\]/, '')
  end
end
