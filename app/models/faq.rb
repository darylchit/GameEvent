class Faq < ActiveRecord::Base
  belongs_to :faq_header
  validates :name, presence: true
  validates :answer, presence: true
  validates :rank, presence: true
  validates :faq_header_id, presence: true
  validates :rank, numericality: { greater_than_or_equal_to: 1, :message => "Must be greater than or equal to 1" }

  default_scope { order('rank asc') }
  scope :live, -> { where(active: true) }
end
