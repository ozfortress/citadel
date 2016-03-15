module ApplicationPermissions
  extend ActiveSupport::Concern

  def user_can_meta?
    user_signed_in? && current_user.can?(:edit, :games)
  end
end
