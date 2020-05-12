class ClanSerializer < ActiveModel::Serializer
  attributes :id, :name, :game_type, :most_active, :game_system, :play_style, :languages, :bio, :minimum_age, :family_friendly, :availability, :ground_rules, :requirements
end
