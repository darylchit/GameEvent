class Api::V1::UserSerializer < ActiveModel::Serializer
  include ProfileHelper
  attributes :id, :username, :avatar_url, :psa_rating, :cancellation_rate, :age,
             :psn_user_name, :xbox_live_user_name, :nintendo_user_name, :pc_user_name,
             :experience, :deleted_account

  def age
    object.public_age ? age_in_years(object.date_of_birth) : nil
  end

  def avatar_url
    if object.avatar_url.starts_with? "http"
      object.avatar_url
    elsif Rails.env.production?
      ActionController::Base.helpers.asset_path object.avatar_url, digest: true
    else
      ActionController::Base.helpers.asset_path object.avatar_url, digest: false
    end
  end
end
