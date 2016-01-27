class TeamsController < ApplicationController
  before_action :require_login, only: [:new, :create]
  before_action :require_team_permission, only: [:edit, :update]

  def index
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(new_team_params)

    if @team.save
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

    redirect_to(team_path(@team))
  end

  private

  def new_team_params
    params.require(:team).permit(:format_id, :name, :description)
  end

  def edit_team_params
    params.require(:team).permit(:name, :description)
  end

  def require_team_permission
    require_login
    @team = Team.find(params[:id])
    redirect_to team_path(@team) unless current_user.can?(:edit, @team) || current_user.can?(:edit, :teams)
  end
end
