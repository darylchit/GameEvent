class Api::V1::SubscriptionPlanSerializer < ActiveModel::Serializer
  attributes :id,:name,:price,:product_id
end
