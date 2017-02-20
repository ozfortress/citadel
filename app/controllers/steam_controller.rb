class SteamController < ApplicationController
  before_action { @user = User.find_by!(steam_id: params[:id]) }

  def show
    if @user
      redirect_to user_path(@user)
    else
      redirect_to users_path
    end
  end
end
