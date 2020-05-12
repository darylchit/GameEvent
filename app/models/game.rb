class Game < ActiveRecord::Base
	extend FriendlyId
	friendly_id :title, use: [:slugged, :finders]

	has_many :game_game_system_joins
	has_many :events, through: :game_game_system_joins
	has_many :game_systems, through: :game_game_system_joins
	has_and_belongs_to_many :clans

	mount_uploader :game_cover, GameCoverUploader
	mount_uploader :game_jumbo, GenericUploader
	mount_uploader :game_jumbo_mobile, GenericUploader
	mount_uploader :game_logo, GenericUploader

	validates :title, presence: { message: "Title is Required" }
	# validates :game_cover, presence: true
	# validates :game_jumbo, presence: true
	# validates :game_logo, presence: true

	scope :new_releases, -> { where('release_date > ?', Time.now) }
	scope :active, -> { where(active: true) }
	def game_title
		title
	end

	def affiliate_network_link=(value)
		self[:affiliate_network_link] = value.to_s.strip
	end

	def should_generate_new_friendly_id?
    title_changed?
  end

end
