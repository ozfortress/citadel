require 'steam_id'

module UsersHelper
  def current_user?
    current_user == @user
  end

  def transfers
    Transfer.where(user: @user).order('created_at DESC').all
  end

  def steam_id
    SteamId.to_str(@user.steam_id)
  end
end
