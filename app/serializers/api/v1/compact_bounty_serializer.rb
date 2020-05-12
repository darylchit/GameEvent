class Api::V1::CompactBountySerializer < ActiveModel::Serializer
  include ProfileHelper
  attributes :id, :start_date_time, :duration, :price_in_cents,
             :details, :will_play, :play_type, :buyer, :title,
             :games, :contract_type,
             # roster
             :waitlist, :confirmed_users_count, :max_roster_size

  def buyer
    Api::V1::UserSerializer.new object.buyer, root: false
  end

  def games
    object.game_game_system_joins.map do | ggs |
      Api::V1::GameGameSystemJoinSerializer.new ggs, root: false
    end
  end

end
