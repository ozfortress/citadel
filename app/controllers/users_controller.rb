class UsersController < ApplicationController
  include UsersPermissions

  before_action only: [:show, :edit, :update, :request_name_change] do
    @user = User.find(params[:id])
  end

  before_action only: [:confirm_email] do
    @user = User.find_by(confirmation_token: params[:token])
  end

  before_action :require_login, only: [:profile, :logout]
  before_action :require_user_permission, only: [:edit, :update, :request_name_change]
  before_action :require_users_permission, only: [:names, :handle_name_change]
  before_action :require_user_confirmation_token, only: :confirm_email
  before_action :require_user_confirmation_not_timed_out, only: :confirm_email

  def index
    @users = User.search(params[:q])
                 .paginate(page: params[:page])
                 .load
  end

  def new
    if steam_data
      @user = User.new(name: params[:name], steam_id: steam_data['uid'])
    else
      redirect_to root_path
    end
  end

  def create
    @user = Users::CreationService.call(new_user_params, flash)

    if @user.persisted?
      sign_in @user

      flash.keep
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def profile
    # replace /profile in path with the path to the current user
    pattern = Regexp.new("^#{Regexp.escape profile_path}")
    subpath = request.fullpath.sub(pattern, '')

    redirect_to user_path(current_user) + subpath
  end

  def show
    @comment          = User::Comment.new
    @comments         = @user.comments.ordered.includes(:created_by)
    @aka              = @user.aka.limit(5).order(created_at: :desc)
    @titles           = @user.titles
    @teams            = @user.teams.order(created_at: :desc)
    @team_transfers   = @user.team_transfers.includes(:team).order(created_at: :desc)
    @roster_transfers = roster_transfers_by_league
    @team_invites     = @user.team_invites.includes(:team).order(created_at: :asc)
    @matches          = @user.matches.pending.includes(:home_team, :away_team)
    @forums_posts     = user_forums_posts.reorder(created_at: :desc).includes(:thread, :created_by).limit(10)
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
    @name_changes = User::NameChange.pending.includes(:user)
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

    names
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

  def steam_data
    session['devise.steam_data']
  end

  def roster_transfers_by_league
    @user.roster_transfers
         .includes(roster: { division: :league })
         .joins(roster: { division: :league })
         .order('leagues.created_at desc', created_at: :desc)
         .chunk(&:league)
         .to_a
  end

  def user_forums_posts
    if current_user == @user
      @user.forums_posts
    else
      @user.public_forums_posts
    end
  end

  def new_user_params
    params.require(:user).permit(:name, :avatar, :description, :email)
          .merge(steam_id: steam_data['uid'])
  end

  def edit_user_params
    common = [:avatar, :remove_avatar, :description, :email]
    permitted = if user_can_edit_users?
                  [:badge_name, :badge_color, :notice]
                else
                  []
                end

    params.require(:user).permit(*(common + permitted))
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
