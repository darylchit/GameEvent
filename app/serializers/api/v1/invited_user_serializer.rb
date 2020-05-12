class Api::V1::InvitedUserSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :status, :created_at
end
