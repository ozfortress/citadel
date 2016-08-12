class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def default_url
    model_name = model.model_name.singular
    'fallback/' + [version_name, model_name, 'avatar_default.png'].compact.join('_')
  end

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
