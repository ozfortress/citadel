class UsersController < ApplicationController
  include UsersPermissions

  before_action only: [:show, :edit, :update,
                       :request_name_change] { @user = User.find(params[:id]) }
  before_action only: [:confirm_email] { @user = User.find_by(confirmation_token: params[:token]) }

  before_action :require_login, only: [:logout]
  before_action :require_user_permission, only: [:edit, :update, :request_name_change]
  before_action :require_users_permission, only: [:names, :handle_name_change]
  before_action :require_user_confirmation_token, only: :confirm_email
  before_action :require_user_confirmation_not_timed_out, only: :confirm_email

  def index
    @users = User.search(params[:q]).paginate(page: params[:page])
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
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def show
    @aka            = @user.aka.limit(5).order(created_at: :desc)
    @titles         = @user.titles
    @teams          = @user.teams.order(created_at: :desc)
    @team_transfers = @user.team_transfers.includes(:team).order(created_at: :desc)
    @team_invites   = @user.team_invites.includes(:team).order(created_at: :asc)
    @rosters        = @user.rosters.includes(division: :league).order(created_at: :desc)
    @matches        = @user.matches.pending.includes(:home_team, :away_team)
  end

  def edit
    @name_change = @user.names.new(name: @user.name)
  end

  def update
    if Users::UpdatingService.call(@user, edit_user_params, flash)
      redirect_to(user_path(@user))
    else
      edit
      render :edit
    end
  end

  def names
  end

  def request_name_change
    @name_change = @user.names.new(name_change_params)

    if @name_change.save
      flash[:notice] = 'Name change request sent!'
      redirect_to(user_path(@user))
    else
      render :edit
    end
  end

  def handle_name_change
    @user = User.find(params[:user_id])
    @name_change = @user.names.pending.find(params[:id])
    Users::NameChangeHandlingService.call(@name_change, current_user, params[:approve] == 'true')

    render :names
  end

  def confirm_email
    if @user.confirm
      flash[:notice] = 'Email successfully confirmed'
      redirect_to user_path(@user)
    else
      flash[:error] = 'Error confirming email'
      redirect_to edit_user_path(@user)
    end
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
    params.require(:user).permit(:avatar, :remove_avatar, :description, :email)
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

  def require_user_confirmation_token
    return if @user

    flash[:error] = 'Invalid confirmation token'
    redirect_to root_path
  end

  def require_user_confirmation_not_timed_out
    return unless @user.confirmation_timed_out?

    flash[:error] = 'Confirmation token timed out.'
    @user.update!(email: nil)
    redirect_to user_path(@user)
  end
end
