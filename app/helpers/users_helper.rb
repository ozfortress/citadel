require 'steam_id'

module UsersHelper
  include UsersPermissions

  def current_user?
    current_user == @user
  end
end
