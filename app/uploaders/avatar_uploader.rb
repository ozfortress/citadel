class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  process resize_to_fit: [200, 200]

  version :thumb do
    process resize_to_fill: [32, 32]
  end

  version :icon do
    process resize_to_fill: [100, 100]
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def content_type_whitelist
    %r{image\/}
  end
end
