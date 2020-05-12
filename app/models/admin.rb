class Admin < ActiveRecord::Base
  has_many :system_notices
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable, :lockable

  validates :email, presence: { message: "Email is Required" }
  validates :email, uniqueness: { case_sensitive: false }

  def password_required?
    # allow blank passowrd, note users will NOT be able to login
    # until this is set this with forgot password
    !password.nil? || !password_confirmation.nil?
  end

end
