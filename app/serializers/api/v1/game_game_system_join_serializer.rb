class Api::V1::GameGameSystemJoinSerializer < ActiveModel::Serializer
  include ProfileHelper
  attributes :id, :game, :game_system

  def game
    g = object.game
    {
      id: g.id,
      game_cover: url_for_image(g.game_cover),
      game_jumbo: url_for_image(g.game_jumbo),
      game_logo:  url_for_image(g.game_logo),
      title:      g.title,
      game_jumbo_mobile: url_for_image(g.game_jumbo_mobile),
    }
  end

  def game_system
    s = object.game_system
    {
      id:           s.id,
      title:        s.title,
      abbreviation: s.abbreviation
    }
  end

  def url_for_image(image)
    if image.present?
      if image.url.starts_with? "http"
        image.url
      elsif Rails.env.production?
        ActionController::Base.helpers.asset_path image.url, digest: true
      else
        ActionController::Base.helpers.asset_path image.url, digest: false
      end
    else
      if Rails.env.production?
        ActionController::Base.helpers.asset_path 'def-cover.jpg', digest: true
      else
        ActionController::Base.helpers.asset_path 'def-cover.jpg', digest: false
      end
    end
  end

end
