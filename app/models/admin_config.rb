class AdminConfig < ActiveRecord::Base
  acts_as_paranoid
  has_many :messages, :as => :notified_object

  validates :name, uniqueness: { :case_sensitive => false }

  scope :mail_signature, -> { find_by_name('mail_signature') }
  scope :user_create_email, -> { find_by_name('user_create_email') }
  scope :clan_create_email, -> { find_by_name('clan_create_email') }
  scope :email_image_css, -> { find_by_name('email_image_css') }
  scope :email_image_width, -> { find_by_name('email_image_width') }
  scope :user_create_subject, -> { find_by_name('user_create_subject') }
  scope :clan_create_subject, -> { find_by_name('clan_create_subject') }
end
