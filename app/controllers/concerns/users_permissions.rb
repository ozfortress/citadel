module UsersPermissions
  extend ActiveSupport::Concern

  def user_can_edit_user?
    user_signed_in? && current_user == @user && current_user.can?(:use, :users) ||
      user_can_edit_users?
  end

  def user_can_edit_users?
    user_signed_in? && current_user.can?(:edit, :users)
  end
end
