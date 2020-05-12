class Link < ActiveRecord::Base
  belongs_to :clan

  validate :name#, presence: true
  validate :url#, presence: true
  # validate :validate_url

  # def validate_url
  #   begin
  #     uri = URI.parse(url)
  #     errors.add(:url, "URL not valid") unless uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
  #   rescue
  #     errors.add(:url, "URL not valid")
  #   end
  # end

end
