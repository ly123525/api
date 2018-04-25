# -*- encoding : utf-8 -*-
class ProductDetailsUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  def extension_whitelist
    %w(jpg jpeg gif png ico)
  end

  def filename
    return if original_filename.blank?
    self.generate_filename
  end

  def store_dir
    "details/#{model.created_at.strftime("%Y%m")}"
  end

  def style_url style_name
    url(thumb: "?x-oss-process=style/#{style_name}")
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, Time.now.strftime("%Y%m%d%H%M%S%L")+SecureRandom.hex(4).to_s)
  end

  def generate_filename
    image = MiniMagick::Image.open(file.path)
    "#{secure_token}-#{image['width']}-#{image['height']}.#{file.extension}"
  end
end