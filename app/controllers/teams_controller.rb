class TeamsController < ApplicationController
  def index
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)

    if @team.save!
      redirect_to team_path(@team)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  private

  def team_params
    params.require(:team).permit(:name, :description)
  end
end
