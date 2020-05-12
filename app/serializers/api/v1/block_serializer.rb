class Api::V1::BlockSerializer < ActiveModel::Serializer
  attributes :id, :blocked_user

  def blocked_user
    Api::V1::UserSerializer.new object.blocked_user, root: false
  end
end
