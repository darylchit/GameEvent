class ClanRank < ActiveRecord::Base

  belongs_to :clan
  has_many :clan_members
  has_many :users, -> { order(:username) }, through: :clan_members

  # bitmask :permissions, :as => [:post_events, :post_chat, :post_notices, :review_applications, :receive_contact]
  # attr_accessor :post_events, :post_chat, :post_notices, :review_applications, :receive_contact
  #validates :title, uniqueness: {scope: [:clan_id]}

  default_scope { order(:default_sort_order) }

  after_save :default_title


  #validates :title, presence: { message: "Title is Required" }
  # before_save :set_permissions
  # ROLES = ClanRank.values_for_permissions
  # def permissions=(permissions)
  #   self.mask = (permissions & values_of_permissions).map { |r| 2**values_of_permissions.index(r)}.inject(0, :+)
  # end

  # def permissions
  #   values_of_permissions.reject do |r|
  #     ((mask.to_i || 0 ) & 2**values_of_permissions.index(r)).zero?
  #   end
  # end
  # def roles
  #   ClanRank.values_for_permissions.map{|p| permissions.include?(p)}
  # end

  # def set_roles _roles
  #   for i in 0..PERMISSIONS.count - 1
  #     permissions << PERMISSIONS[i] if _roles[i]
  #   end
  # end

#   def roles=(roles)
#     self.permissions = (roles & ROLES).map { |r| 2**ROLES.index(r)
# }.inject(0, :+)
#   end

#   def roles
#     ROLES.reject do |r|
#       ((permissions.to_i || 0) & 2**ROLES.index(r)).zero?
#     end
#   end

  # def post_events?
  #   false
  #   # self.post_events?
  # end

  # def post_chat?
  #   false
  #   # post_chat?
  # end

  # def post_notices?
  #   # post_notices?
  # end

  # def review_applications?
  #   review_applications?
  # end

  # def receive_contact?
  #   receive_contact?
  # end

  private
  def default_title
    if self.title.strip.empty?
      self.title = "Rank #{default_sort_order}"
      self.save
    end
  end
  # def set_permissions
  #   permissions = []
  #   permissions << :post_events if [true, "true"].include?(post_events)
  #   permissions << :post_chat if [true, "true"].include?(post_chat)
  #   permissions << :post_notices if [true, "true"].include?(post_notices)
  #   permissions << :review_applications if [true, "true"].include?(review_applications)
  #   permissions << :receive_contact if [true, "true"].include?(receive_contact)
  #   p permissions
  #   self.permissions = permissions
  # end

end
