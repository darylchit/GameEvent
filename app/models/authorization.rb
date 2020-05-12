class Authorization < ActiveRecord::Base

	serialize :discord_channels, Array

  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  # validates_uniqueness_of :uid, :scope => :provider

# Scopes
  scope :discord, -> { where("provider = ?", 'discord') }

  def self.find_from_hash(hash, guild_id, user)
    find_by_provider_and_uid_and_guild_id_and_user_id(hash['provider'], hash['uid'], guild_id, user.id)
  end

  def self.create_from_hash(hash,  guild_id, user = nil)
    # user ||= User.create_from_hash!(hash)
    if user.present?
      auth = user.authorizations.find_by_provider(hash['provider'])
      if auth
        auth.uid = hash['uid']
				auth.guild_id = guild_id
        auth.save
      else
        Authorization.create(user: user, uid: hash['uid'], provider: hash['provider'], guild_id: guild_id)
      end
    end
  end
end
