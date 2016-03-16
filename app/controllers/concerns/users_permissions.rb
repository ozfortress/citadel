module UsersPermissions
  extend ActiveSupport::Concern

  def user_can_edit_user?
    user_signed_in? && current_user == @user
  end
end
