module GamesHelper

  def game_cover_html(game, link='')
    game_image_html(game, game.game_cover, 'game-cover', link)
  end

  def game_image_html(game, image, klass, link)
    klass += ' has-image' if image.present?
    html = "<div class=\"#{klass}\">"
    html += "<a href=\"#{link}\">" if link.present?
    html += image_tag(image) if image.present?
    html += image_tag('def-cover.jpg') unless image.present?
    html += "</a>" if link.present?
    html += "</div>"
    raw html
  end

  def game_release_year_range
    cur_year = Date.today.year
    [*2000..cur_year+3]
  end

  def game_release_year
    if params[:id]
      id = params[:id]
      game = Game.find(id)
      if game.release_date.present?
        return game.release_date.year
      else
        return Date.today.year
      end
    else
      return Date.today.year
    end
  end

  def game_release_month
    if params[:id]
      id = params[:id]
      game = Game.find(id)
      if game.release_date.present?
        return game.release_date.month
      else
        return Date.today.month
      end
    else
      return Date.today.month
    end
  end

  def game_release_day
    if params[:id]
      id = params[:id]
      game = Game.find(id)
      if game.release_date.present?
        return game.release_date.day
      else
        return Date.today.day
      end
    else
      return Date.today.day
    end
  end

  def game_systems_for_game(game)
    new_systems = []
    systems = game.game_systems.map{|sys|[sys.title, sys.id]}
    systems.each do |t|
       if t.first == 'PC'
         new_systems << ['PC (Steam)', t.last ]
         new_systems << ['PC (Battle)', t.last]
         new_systems << ['PC (Origins)', t.last]
       else
         new_systems << t
      end
    end
    new_systems
  end

end
