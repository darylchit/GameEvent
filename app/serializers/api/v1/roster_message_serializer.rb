class Api::V1::RosterMessageSerializer < ActiveModel::Serializer
  attributes :id, :message, :user, :created_at

  def user
    Api::V1::UserSerializer.new object.user, root: false
  end
end
