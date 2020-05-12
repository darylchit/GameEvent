class Notice < ActiveRecord::Base
  validates_presence_of :title, :message => "Title is Required"
  validates_presence_of :body, :message => "Body is Required"

  # grab only current notices from provided collection or all
  def self.current notices = self.all
    return notices.select{ |n| n.expiration.nil? || n.expiration > Time.now }.sort_by{|n| n.updated_at}.reverse
  end
end
