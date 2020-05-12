class VideoUrl < ActiveRecord::Base
  belongs_to :video_urlable, polymorphic: true
  validate :url #, presence: true
  validate :validate_url

   def youtube_url?
     url.include?(YOUTUBE_PREFIX) || url.include?(YOUTUBECOM_PREFIX)
   end

   def twitch_url?
     url.include?(TWITCH_PREFIX)
   end

   def mixer_url?
     url.include?(MIXER_PREFIX)
   end

   def video_id
     code = url
     if twitch_url?
       code.delete(TWITCH_PREFIX)[0..8]
     elsif youtube_url?
       code.delete(YOUTUBE_PREFIX).delete(YOUTUBECOM_PREFIX)[0..8]
     end
   end
   private

   TWITCH_PREFIX = 'twitch.tv/'
   YOUTUBECOM_PREFIX = 'youtube.com/'
   YOUTUBE_PREFIX= 'youtu.be/'
   MIXER_PREFIX = 'mixer.com/'

    def validate_url
      unless url.present? && (url.include?(TWITCH_PREFIX) || url.include?(YOUTUBE_PREFIX) || url.include?(YOUTUBECOM_PREFIX) || url.include?(MIXER_PREFIX))
        errors.add(:url, 'Please only submit YouTube, Twitch or Mixer videos.')
      end
    end

end
