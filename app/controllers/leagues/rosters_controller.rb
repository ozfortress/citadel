module Leagues
  class RostersController < ApplicationController
    include LeaguePermissions

    before_action :require_not_entered, only: [:new, :create]
    before_action :require_signuppable, only: [:new, :create]
    before_action :require_any_team_permission, only: [:new, :create]
    before_action :require_user_league_permission, only: [:index]

    def index
    end

    def new
      @competition = Competition.find(params[:league_id])
      @roster = @competition.divisions.first.rosters.new

      if params.key?(:team_id)
        team = Team.find(params[:team_id])
        redirect_to league_path(@competition) if team.entered?(@competition)

        @roster.team = team
        @roster.name = team.name
      end
    end

    def create
      @competition = Competition.find(params[:league_id])
      @roster = @competition.divisions.first.rosters.new(roster_params)
      @roster.team = Team.find(params[:team_id])

      if @roster.save
        redirect_to league_path(@competition)
      else
        render :new
      end
    end

    def show
      @competition = Competition.find(params[:league_id])
      @roster = @competition.rosters.find(params[:id])
    end

    def edit
      @competition = Competition.find(params[:league_id])
      @roster = @competition.rosters.find(params[:id])
    end

    def update
      @competition = Competition.find(params[:league_id])
      @roster = @competition.rosters.find(params[:id])

      if @roster.update(roster_params)
        redirect_to league_roster_path(@competition, @roster)
      else
        render :edit
      end
    end

    private

    def roster_params
      params.require(:competition_roster).permit(:name, :description, :division_id, player_ids: [])
    end

    def require_signuppable
      @competition = Competition.find(params[:league_id])
      redirect_to league_path(@competition) unless @competition.signuppable?
    end

    def require_not_entered
      @competition = Competition.find(params[:league_id])
      redirect_to league_path(@competition) if current_user.entered?(@competition)
    end

    def require_any_team_permission
      redirect_to league_path(@competition) unless user_signed_in? &&
                                                   current_user.can_any?(:edit, :team)
    end

    def require_user_league_permission
      @competition = Competition.find(params[:league_id])
      redirect_to league_path(@competition) unless user_can_edit_league?
    end
  end
end
