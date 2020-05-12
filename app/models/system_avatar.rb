class SystemAvatar < ActiveRecord::Base

  def file_path
    #TODO this should be a little more configurable
    "avatars/#{name}"
  end
end
