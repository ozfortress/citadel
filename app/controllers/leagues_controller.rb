class LeaguesController < ApplicationController
  include LeaguePermissions

  before_action :require_user_leagues_permission, only: [:new, :create]
  before_action :require_user_league_permission, only: [:edit, :update]

  def index
  end

  def new
    @competition = Competition.new
  end

  def create
    @competition = Competition.new(league_params)

    if @competition.save
      redirect_to league_path(@competition)
    else
      render :new
    end
  end

  def show
    @competition = Competition.find(params[:id])
  end

  def edit
    @competition = Competition.find(params[:id])
  end

  def update
    @competition = Competition.find(params[:id])

    if @competition.update(league_params)
      redirect_to league_path(@competition)
    else
      render :edit
    end
  end

  private

  def league_params
    params.require(:competition).permit(:name, :description, :format_id)
  end

  def require_user_leagues_permission
    redirect_to leagues_path unless user_can_edit_leagues?
  end

  def require_user_league_permission
    @competition = Competition.find(params[:id])
    redirect_to league_path(@competition) unless user_can_edit_league?
  end
end
