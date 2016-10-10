class SteamController < ApplicationController
  before_action { @user = User.find_by(steam_id: params[:id]) }

  def show
    redirect_to user_path(@user)
  end
end
