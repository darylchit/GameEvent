# encoding: utf-8

class ClanUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  #storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/clans/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  version :jumbo do
    process :resize_jumbo_image
  end

  version :mobile_jumbo do
    process :resize_mobile_jumbo_image
  end

  version :cover do
    process :resize_cover_image
  end

  def resize_jumbo_image
    img = Magick::Image.read(current_path)
    width = img[0].columns
    height = img[0].rows
    if width < 1200
      resize_to_fill(1200, 500)
    else
      resize_to_fit(1200, 500)
    end
  end

  def resize_mobile_jumbo_image
    img = Magick::Image.read(current_path)
    width = img[0].columns
    if width < 550
      resize_to_fill(550,300)
    else
      resize_to_fit(550,330)
    end
  end

  def resize_cover_image
    img = Magick::Image.read(current_path)
    width = img[0].columns
    if width < 400
      resize_to_fill(400,400)
    else
      resize_to_fit(400,400)
    end
  end


  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
