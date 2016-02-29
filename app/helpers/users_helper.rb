require 'steam_id'

module UsersHelper
  def current_user?
    current_user == @user
  end

  def transfers
    Transfer.where(user: @user).order('created_at DESC').all
  end
end
