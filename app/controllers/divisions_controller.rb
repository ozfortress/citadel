class DivisionsController < ApplicationController
  include LeaguePermissions

  before_action :require_user_league_permission

  def new
    @competition = Competition.find(params[:league_id])
    @div = @competition.divisions.new
  end

  def create
    @competition = Competition.find(params[:league_id])
    @div = @competition.divisions.new(division_params)

    if @div.save
      redirect_to edit_league_path(@competition)
    else
      render :create
    end
  end

  def edit
    @competition = Competition.find(params[:league_id])
    @div = @competition.divisions.find(params[:id])
  end

  def update
    @competition = Competition.find(params[:league_id])
    @div = @competition.divisions.find(params[:id])

    if @div.update(division_params)
      redirect_to edit_league_path(@competition)
    else
      render :edit
    end
  end

  def destroy
    @competition = Competition.find(params[:league_id])

    if @competition.divisions.destroy(params[:id])
      redirect_to edit_league_path(@competition)
    else
      render :edit
    end
  end

  private

  def division_params
    params.require(:division).permit(:name, :description)
  end

  def require_user_league_permission
    @competition = Competition.find(params[:league_id])
    redirect_to league_path(@competition) unless user_can_edit_league?
  end
end
