module Leagues
  class RostersController < ApplicationController
    before_action :require_not_entered
    before_action :require_signuppable
    before_action :require_any_team_permission

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
  end
end
