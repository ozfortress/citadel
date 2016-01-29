class TeamsController < ApplicationController
  before_action :require_login, only: [:new, :create, :leave]
  before_action :require_team_permission, only: [:edit, :update, :grant, :revoke, :recruit, :invite]

  def index
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(new_team_params)

    if @team.save
      @team.add_player(current_user)
      current_user.grant(:edit, @team)
      redirect_to team_path(@team)
    else
      render :new
    end
  end

  def show
    @team = Team.find(params[:id])
  end

  def edit
    @team = Team.find(params[:id])
  end

  def update
    @team = Team.find(params[:id])

    @team.update(edit_team_params)

    redirect_to team_path(@team)
  end

  def recruit
    @team = Team.find(params[:id])
  end

  def invite
    @team = Team.find(params[:id])
    user = User.find(params[:user_id])

    @team.invite(user) unless @team.invited?(user) || @team.on_roster?(user)
    redirect_to team_path(@team)
  end

  def leave
    @team = Team.find(params[:id])

    if params.key? :user_id
      require_team_permission
      user = User.find(params[:user_id])
    else
      user = current_user
    end

    @team.remove_player(user) if @team.on_roster?(user)
    redirect_to :back
  end

  # Permissions
  def grant
    @team = Team.find(params[:id])
    user = User.find(params[:user_id])

    user.grant(:edit, @team)
    redirect_to :back
  end

  def revoke
    @team = Team.find(params[:id])
    user = User.find(params[:user_id])

    user.revoke(:edit, @team)
    redirect_to :back
  end

  private

  def new_team_params
    params.require(:team).permit(:format_id, :name, :description)
  end

  def edit_team_params
    params.require(:team).permit(:name, :description)
  end

  def require_team_permission
    @team = Team.find(params[:id])
    redirect_to team_path(@team) unless user_can_edit_team?
  end

  helper_method :user_can_edit_team?
  def user_can_edit_team?
    user_signed_in? &&
      (current_user.can?(:edit, @team) || current_user.can?(:edit, :teams))
  end
end
