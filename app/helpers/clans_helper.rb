module ClansHelper
HTTPS = "https://"
  def clan_link_label(type)
    case type
      when "facebook"
        "Username"
      when "twitter"
        "Handle"
      when "youtube"
        "Channel"
      when "twitch"
        "Username"
      when "bungie"
        "ID"
      when "discord"
        "Channel ID"
      when "google"
        "+"
      when "curse"
        "Channel"
      end

  end

  def clan_times_display(list)
    if list.size >= 2
      arr = JSON.parse(list).reject { |item| item.nil? || item == '' } rescue ""
      html = ''
      if arr.size == 1
        html += arr[0]
      else
        arr.each_with_index do |item, index|
          if index != arr.size - 1
            html += item + ' | '
          else
            html += item
          end
        end
      end
      raw html
    else
      raw "&mdash;"
    end
  end

  def clan_pop_games(clan)
    html = ''
    clan.top_3_games.each_with_index do |game, index|
      html += game.title + (index == (clan.top_3_games.count - 1) ? '' : ', ')
    end
    raw html
  end

  def clan_pop_games_truncated(clan)
    html = '<span data-toggle="tooltip" title="'
      clan.top_3_games.each_with_index do |game, index|
        if index != 0
          html += game.title + (index == (clan.top_3_games.count - 1) ? '' : ', ')
        end
      end
    html += '">'
    html += clan.top_3_games.first.title
    if clan.top_3_games.count > 1
      html += ' +' + (clan.top_3_games.count - 1).to_s
    end
    html += '</span>'
    raw html
  end

  def clan_pop_systems(clan)
    html = ''
    clan.top_3_systems.each_with_index do |system, index|
      html += system.abbreviation + (index == (clan.top_3_systems.count - 1) ? '' : ', ')
    end
    raw html
  end

  def clan_pop_systems_truncated(clan)
    html = '<span data-toggle="tooltip" title="'
      clan.top_3_systems.each_with_index do |system, index|
        if index != 0
          html += system.abbreviation + (index == (clan.top_3_systems.count - 1) ? '' : ', ')
        end
      end
    html += '">'
    #html += clan.top_3_systems.first.title
    html += clan.top_3_systems.first.abbreviation
    if clan.top_3_systems.count > 1
      html += ' +' + (clan.top_3_systems.count - 1).to_s
    end
    html += '</span>'
    raw html
  end

  def clan_cover_url(clan)
    if clan.cover.present?
      clan.cover.url(:cover)
    elsif clan.clan_avatar.present?
      clan.clan_avatar.avatar_path
    else
      'clan_cover.jpg'
    end
  end

  def clan_mobile_jumbo_url(clan)
    if clan.mobile_jumbo.present?
      clan.mobile_jumbo.url(:mobile_jumbo)
    elsif clan.clan_avatar.present?
      clan.clan_avatar.mobile_jumbo_path
    else
      'clan_mobile_jumbo.jpg'
    end
  end

  def clan_jumbo_url(clan)
    if clan.jumbo.present?
       clan.jumbo.url(:jumbo)
    elsif clan.clan_avatar.present?
      clan.clan_avatar.jumbo_path
    else
      'clan_jumbo.jpg'
    end
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

  def game_display(clan)
    clan.top_3_games.map(&:title).join(' ')

  end

  def system_display(clan)
    clan.top_3_systems.map(&:abbreviation).join(' ')
  end

  def short_game_type(game_type)
    game_type_name = ''
    game_type.split(' ').each do |i|
      game_type_name+=game_type[i][0].capitalize
    end if game_type.present?
    return game_type_name
  end

  def add_http_to_link(link)
    link.strip!
    if link.start_with?("https://") || link.start_with?("http://")
      link
    else
      HTTPS + link
    end
  end
  
  def get_events_of_clan(clan)
    @clan_events = clan.events.where("start_at >= ?", Time.zone.now).count 
  end
end
