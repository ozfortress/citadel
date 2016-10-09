class UsersController < ApplicationController
  include UsersPermissions
  include Searchable

  before_action except: [:index, :new, :create, :logout, :names,
                         :handle_name_change] { @user = User.find(params[:id]) }

  before_action :require_login, only: [:logout]
  before_action :require_user_permission, only: [:edit, :update, :request_name_change]
  before_action :require_users_permission, only: [:names, :handle_name_change]

  def index
    @users = User.search_all(params[:q]).paginate(page: params[:page])
  end

  def new
    steam_data = session['devise.steam_data']

    if steam_data
      @user = User.new(name: params[:name], steam_id: steam_data['uid'])
    else
      redirect_to root_path
    end
  end

  def create
    steam_data = session['devise.steam_data']
    @user = User.new(new_user_params.merge(steam_id: steam_data['uid']))

    if @user.save
      @user.names.create!(name: @user.name, approved_by: @user)
      sign_in @user
      render :show
    else
      render :new
    end
  end

  def show
  end

  def edit
    @name_change = @user.names.new(name: @user.name)
  end

  def update
    if @user.update(edit_user_params)
      redirect_to(user_path(@user))
    else
      render :edit
    end
  end

  def names
  end

  def request_name_change
    @name_change = @user.names.new(name_change_params)

    if @name_change.save
      redirect_to(user_path(@user))
    else
      render :edit
    end
  end

  def handle_name_change
    @user = User.find(params[:user_id])
    @name_change = @user.pending_names.find(params[:id])
    @name_change.approve!(@user, params[:approve] == 'true')

    render :names
  end

  def logout
    sign_out current_user

    redirect_back(fallback_location: root_path)
  end

  private

  def new_user_params
    params.require(:user).permit(:name, :avatar, :description)
  end

  def edit_user_params
    params.require(:user).permit(:avatar, :remove_avatar, :description)
  end

  def name_change_params
    params.require(:name_change).permit(:name)
  end

  def require_user_permission
    redirect_to user_path(@user) unless user_can_edit_user?
  end

  def require_users_permission
    redirect_to pages_home_path unless user_can_edit_users?
  end
end
