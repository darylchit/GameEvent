class Blog < ActiveRecord::Base
  acts_as_paranoid

  has_many :messages, :as => :notified_object

  validates :title, presence: true
  validates :value, presence: true
  validates :value2, presence: true

  enum blog_type: [ :all_players, :all_clans, :active_clans, :inactive_clans ]

  validates :blog_type,  presence: { message: "Required" }


  def published?
    !published_at.nil?
  end

  def publish!
    if !published?
      Blog.delay.publish_delever(id)
      update(published_at: Time.now)
    end
  end

  def self.publish_delever(id)
   blog = Blog.find_by_id(id)
   if blog.present? && blog.published?
     blog.send_notices!
     Blog.send_mail!(id)
   end
  end

  def send_notices!
    if published?
      message = self.messages.find_or_create_by(message_type: 'site_notice')
      if all_players?
        User.select('id').each do |user|
          user.receipts.find_or_create_by(message: message, message_type: message.message_type)
        end
      elsif all_clans?
        Clan.with_deleted.each do |clan|
          clan.host.receipts.find_or_create_by(message: message, message_type: message.message_type)
        end
      elsif active_clans?
        Clan.all.each do |clan|
          clan.host.receipts.find_or_create_by(message: message, message_type: message.message_type)
        end
      elsif inactive_clans?
        Clan.deleted.each do |clan|
          clan.host.receipts.find_or_create_by(message: message, message_type: message.message_type)
        end
      end
    end
  end

  def self.send_mail!(id)
    blog = Blog.find_by_id(id)
    if blog.present? & blog.published?

      if blog.all_players?
        User.select('id, notif_email').where(notif_email: true).each do |user|
          Blog.delay(priority: 9).send_blog_to_user("#{blog.id},#{user.id}")
        end
      elsif blog.all_clans?
        Clan.with_deleted.each do |clan|
          Blog.delay(priority: 9).send_blog_to_user("#{blog.id},#{clan.host_id}") if clan.host.notif_email?
        end
      elsif blog.active_clans?
        Clan.all.each do |clan|
          Blog.delay(priority: 9).send_blog_to_user("#{blog.id},#{clan.host_id}") if clan.host.notif_email?
        end
      elsif blog.inactive_clans?
        Clan.deleted.each do |clan|
          Blog.delay(priority: 9).send_blog_to_user("#{blog.id},#{clan.host_id}") if clan.host.notif_email?
        end
      end

    end
  end

  def self.send_blog_to_user(id_user_id)
    id , user_id = id_user_id.split(',')
    blog = Blog.find_by_id(id)
    user = User.find_by_id(user_id)
    if blog.present? && user.present? && user.notif_email?
      ApplicationMailer.blog_mail(user, blog).deliver_now
    end
  end

end
