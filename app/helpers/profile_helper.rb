module ProfileHelper

  def twitch_flash_vars(url)
    bits = url.split('/')
    videoId = bits.last
    channel = bits[bits.length - 3]
    raw "channel=#{channel}&amp;auto_play=false&amp;&amp;play=false&amp;auto_play=false&amp;start_volume=25&amp;videoId=v#{videoId}"
  end
  def youtube_embed_url(url)
    videoId = if url.index('watch').present? # in case people ignore the hint and use the page URL
      bits = url.split('=')
      bits.last
    else
      url.split('/').last
    end
    raw "https://www.youtube.com/embed/#{videoId}"
  end

  def countries_list
    { "US"=>"United States", "PR" => 'Puerto Rico' }.merge(ISO3166::Country.translations).invert
  end

  def age_in_years(birthday)
    (Time.now.to_s(:number).to_i - birthday.to_time.to_s(:number).to_i)/10e9.to_i
  end

end
