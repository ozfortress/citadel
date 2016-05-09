module Leagues
  class RostersController < ApplicationController
    include LeaguePermissions

    before_action { @competition = Competition.find(params[:league_id]) }
    before_action except: [:index, :new, :create] do
      @roster = @competition.rosters.find(params[:id])
    end

    before_action :require_signuppable, only: [:new, :create]
    before_action :require_any_team_permission, only: [:new, :create]
    before_action :require_user_league_permission, except: [:new, :create, :show, :destroy]
    before_action :require_user_destroy_permission, only: [:destroy]

    def index
    end

    def new
      @roster = @competition.divisions.first.rosters.new

      if params.key?(:team_id)
        team = Team.find(params[:team_id])
        redirect_to league_path(@competition) if team.entered?(@competition)

        @roster.team = team
        @roster.name = team.name
      end
    end

    def create
      @roster = @competition.divisions.first.rosters.new(roster_params)
      @roster.team = Team.find(params[:team_id])

      if @roster.save
        redirect_to league_path(@competition)
      else
        render :new
      end
    end

    def show
    end

    def edit
    end

    def update
      if @roster.update(roster_params)
        redirect_to league_roster_path(@competition, @roster)
      else
        render :edit
      end
    end

    def review
    end

    def approve
      if @roster.update(roster_approve_params.merge(approved: true))
        redirect_to league_roster_path(@competition, @roster)
      else
        render :review
      end
    end

    def destroy
      if @roster.destroy
        redirect_to league_path(@competition)
      else
        render :show
      end
    end

    private

    def roster_params
      params.require(:competition_roster).permit(:name, :description, :division_id, player_ids: [])
    end

    def roster_approve_params
      params.require(:competition_roster).permit(:name, :division_id)
    end

    def require_signuppable
      redirect_to league_path(@competition) unless @competition.signuppable?
    end

    def require_any_team_permission
      redirect_to league_path(@competition) unless user_signed_in? &&
                                                   current_user.can_any?(:edit, :team)
    end

    def require_user_league_permission
      redirect_to league_path(@competition) unless user_can_edit_league?
    end

    def require_user_destroy_permission
      redirect_to league_path(@competition) unless user_can_edit_league? ||
                                                   user_signed_in? &&
                                                   current_user.can?(:edit, @roster.team)
    end
  end
end
