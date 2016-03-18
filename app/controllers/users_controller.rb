class UsersController < ApplicationController
  include UsersPermissions

  before_action except: [:index, :new, :create, :logout,
                         :grant_meta, :revoke_meta] { @user = User.find(params[:id]) }

  before_action :require_login, only: [:logout]
  before_action :require_user_permission, only: [:edit, :update]

  def index
    @users = if params[:q].blank?
               User.all
             else
               User.simple_search(params[:q]).records
             end
  end

  def new
    steam_data = session['devise.steam_data']
    @user = User.new(name: params[:name], steam_id: steam_data['uid'])
  end

  def create
    steam_data = session['devise.steam_data']
    @user = User.new(user_params.update(steam_id: steam_data['uid']))

    if @user.save
      sign_in @user
      render :show
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to(user_path(@user))
    else
      render :edit
    end
  end

  def logout
    sign_out current_user
    redirect_to(:back)
  end

  # Debug
  # :nocov:
  def grant_meta
    current_user.grant(:edit, :games)
    current_user.grant(:edit, :teams)
    current_user.grant(:edit, :competitions)
    redirect_to(:back)
  end

  def revoke_meta
    current_user.revoke(:edit, :games)
    current_user.revoke(:edit, :teams)
    current_user.revoke(:edit, :competitions)
    redirect_to(:back)
  end
  # :nocov:

  private

  def user_params
    params.require(:user).permit(:name, :description)
  end

  def require_user_permission
    redirect_to user_path(@user) unless user_can_edit_user?
  end
end
