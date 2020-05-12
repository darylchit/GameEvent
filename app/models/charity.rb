class Charity < ActiveRecord::Base

	has_many :users

	mount_uploader :charity_logo, GenericUploader

	validates :charity_name, presence: { message: "Charity Name is Required" }
	validates :charity_about, presence: { message: "Charity About is Required" }
	validates :charity_url, presence: { message: "Charity Url is Required" }
	#validates :charity_logo, presence: true

end
