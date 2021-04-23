class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def default_url
    model_name = model.model_name.singular
    path = 'fallback/' + [version_name, model_name, 'avatar_default.png'].compact.join('_')

    ActionController::Base.helpers.asset_path path
  end

  def store_dir
    'uploads/avatars/' + model.model_name.plural
  end

  def filename
    "#{model.id}-#{token}.#{file.extension}" if original_filename.present?
  end

  process resize_to_fit: [200, 200]

  version :thumb do
    process resize_to_fill: [32, 32]
  end

  version :icon do
    process resize_to_fill: [100, 100]
  end

  before :cache, :reset_token

  def extension_white_list
    %w[jpg jpeg png]
  end

  def content_type_allowlist
    %r{image/}
  end

  private

  def token_field
    "#{mounted_as}_token"
  end

  def token
    token = model.send(token_field)

    token || model.send(token_field + '=', SecureRandom.hex(12))
  end

  def reset_token(_file)
    model.send(token_field + '=', nil)
  end
end
