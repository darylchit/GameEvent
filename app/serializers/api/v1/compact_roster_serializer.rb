class Api::V1::CompactRosterSerializer < ActiveModel::Serializer
  attributes :id, :start_date_time, :duration, :price_in_cents, :status,
             :details, :will_play, :play_type, :private, :buyer

  def buyer
    b = object.buyer
    {
      username:   b.username,
      avatar_url: b.avatar_url
    }
  end

end
