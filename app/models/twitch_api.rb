# @class Interacts with the Twitch module installed by Kappa.
# @see https://github.com/schmich/kappa

class TwitchAPI

  # client id is not required however Twitch will rate limit
  @@id = ENV['twitch_client_id']
  @@sec = ENV['twitch_secret']

  # @method Configure client id for API calls. This is not needed
  # however Twitch will place rate limits if not present.
  # @return nil
  def self.configure
    Twitch.configure{ |c| c.client_id = @@id }
  end

  # @method Grab user's stream from Twitch. This will return the user
  # stream object however user.channel is also available.
  # Useful attributes after running u = TwitchAPI::user_stream(user):
  #        u.url
  #        u.preview_url
  #        u.game_name
  #        u.viewer_count
  #        u.channel.display_name
  #        u.channel.status
  # Documentation: http://www.rubydoc.info/gems/kappa/Twitch/V2/Stream
  # @param user's twitch username.
  # @return Twitch::Stream || false
  def self.user_stream user
    type = user.class.name == 'User' ? user.twitch_video_url : user.twitch
    if type
      configure
      # The db contains some mixmatched formats for twitch URLs.
      # Since some are full url and some are only username, we can simply
      # split and grab last. Split on username alone still returns username.
      handle = user.class.name == 'User' ? user.twitch_video_url : user.twitch
      username = handle.split('/').last
      twitch_user = Twitch.users.get(username) rescue nil
      return !twitch_user || !twitch_user.stream ? false : twitch_user.stream
    else
      false
    end
  end

  # @method Find which users if any in DB are streaming on Twitch
  # @see self.user_stream
  # @return Array of hashes: stream->Twitch::Stream obj & user->User for that stream
  #         e.g. q = TwitchAPI.find_streaming_users
  #              "#{ q.first[:user].username } is streaming #{ q.first[:stream].game_name }"
  def self.find_streaming_users
    configure
    streams = []
    res = []
    # There are both nil & "" in db
    set = User.pluck(:twitch_video_url).reject!{ |c| c == "" }.compact rescue nil
    if set

      begin
        Twitch.streams.find(channel: set){ |user_stream| streams << user_stream }
        # After sorting by most viewers built array of hashes containing
        # a stream and its corresponding user from the db.
        streams.sort_by{ |u| u.viewer_count }.reverse.each do |s|
          user = User.where("twitch_video_url ilike '%#{s.channel.name}%'").first
          if user
            res << {
              stream: s,
              user: user,
              game: Game.where("title ilike '%#{s.game_name}%'").first
            }
          end
        end
      rescue
        return false
      end

      return res.empty? ? false : res
    else
      return false
    end
  end

end
