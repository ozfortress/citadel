class UsersController < ApplicationController
  def new
    @user = User.new
    @user.name = params[:name]
  end

  def create
    user = User.new(user_params)

    steam_data = session['devise.steam_data']
    user.steam_id = steam_data['uid']

    if user.save
      p "SUCCESS"
      sign_in_and_redirect user
    else
      redirect_to pages_home_url
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def logout
    p session['devise.steam_data']
    session.delete('devise')
    p session['devise.steam_data']
    reset_session
    redirect_to(:back)
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
