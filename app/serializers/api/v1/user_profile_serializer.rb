class Api::V1::UserProfileSerializer < Api::V1::UserSerializer
  attributes :favorite_id, :block_id, :personality_rating, :approval_rating,
             :generosity_rating, :will_play, :newbie_patience_level, :language,
             :may_record_or_stream, :bio, :ground_rules, :twitch_video_url,
             :youtube_video_url, :events, :is_premium

  def favorite_id
    fav = serialization_options[:current_user].favorites.find_by :favorited_user => object
    if fav.present?
      fav.id
    end
  end

  def block_id
    block = serialization_options[:current_user].blocks.find_by :blocked_user => object
    if block.present?
      block.id
    end
  end

  def events
    serialization_options[:events].map do |e|
      if e.roster?
        Api::V1::CompactBountySerializer.new Roster.find(e.id), root: false
      elsif e.bounty?
        Api::V1::CompactBountySerializer.new Bounty.find(e.id), root: false
      else
        Api::V1::CompactContractSerializer.new e, root: false
      end
    end
  end

  def is_premium
    object.is_premium?
  end
  
end
