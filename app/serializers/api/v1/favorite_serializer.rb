class Api::V1::FavoriteSerializer < ActiveModel::Serializer
  attributes :id, :favorited_user

  def favorited_user
    Api::V1::UserSerializer.new object.favorited_user, root: false
  end
end
