class Api::V1::LoginUserSerializer < ActiveModel::Serializer
  include ProfileHelper
  attributes :id, :username, :avatar_url, :psa_rating, :cancellation_rate, :age,
              :approval_rating, :authentication_token, :bio,
             :contracts_completed, :country, :created_at, :updated_at,
             :date_of_birth, :email, :generosity_rating,
             :language,  :newbie_patience_level,
             :nintendo_user_name, :paypal_email, :pc_user_name, :personality_rating,
             :playing_for_charity, :psa_rating, :psn_user_name,
             :public_age, :required_approval_rating, :required_cancellation_rate,
             :required_personality_rating, :required_psa_rating, :required_skill_rating,
             :skill_rating, :timezone, :trial_expiration, :twitch_video_url,
             :username, :will_play, :xbox_live_user_name, :youtube_video_url,
             :game_game_system_joins, :experience, :is_premium, :ios_subscription_expiration,

             #notifications
             :notif_system, :notif_push, :notif_sms, :notif_games

  def age
    object.public_age ? age_in_years(object.date_of_birth) : nil
  end

  def game_game_system_joins
    object.game_game_system_joins.map do | ggs |
      Api::V1::GameGameSystemJoinSerializer.new ggs, root: false
    end
  end

  def is_premium
    object.is_premium?
  end

  def ios_subscription_expiration
    if object.trial_expiration == nil
      #lifetime users always have a 5 year "subscription"
      Date.today() + 5.year
    elsif object.active_ios_subscription.present?
      #TODO: return the last subscription date not only if the active one
      object.active_ios_subscription.ends_on
    end
  end

end
