class ContactRequest < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: { message: "Name is Required" }
  validates :message, presence: { message: "Message is Required" }
  validates :contact_type, presence: { message: "Contact Type is Required" }
  validates_presence_of :email, :if => lambda { self.user.nil? }, :message => "Email is Required"
  validates :email, :email => true

  after_save :send_emails

  def send_emails
    #self.send_user_email
    self.send_admin_email
  end

  def send_user_email
    e = ContactRequestMailer.send_user_email(self)
    if Rails.env.development?
      puts e
    else
      e.deliver_now
    end
  end

  def send_admin_email
    Admin.all.each do |a|
      e = ContactRequestMailer.send_admin_email(self, a)
      if Rails.env.development?
        puts e
      else
        e.deliver_now
      end
    end
  end
end
