module MetaHelper
  def has_meta
    user_signed_in? && current_user.can?(:edit, :games)
  end
end
