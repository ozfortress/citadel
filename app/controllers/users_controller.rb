class UsersController < ApplicationController
  def new
    @user = User.new
    @user.name = params[:name]
  end

  def create
    @user = User.new(user_params)

    steam_data = session['devise.steam_data']
    @user.steam_id = steam_data['uid']

    if @user.save
      sign_in_and_redirect @user
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])

    redirect_to user_url(@user) unless can_edit?
  end

  def update
    @user = User.find(params[:id])

    @user.update(user_params) if can_edit?

    redirect_to(:back)
  end

  def logout
    reset_session
    redirect_to(:back)
  end

  # Debug
  def grant_meta
    current_user.grant(:edit, :games)
    redirect_to(:back)
  end

  def revoke_meta
    current_user.revoke(:edit, :games)
    redirect_to(:back)
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end

  def can_edit?
    @user == current_user
  end
end
