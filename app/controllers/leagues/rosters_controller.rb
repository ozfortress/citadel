module Leagues
  class RostersController < ApplicationController
    include RosterPermissions

    before_action { @competition = Competition.find(params[:league_id]) }
    before_action except: [:index, :new, :create] do
      @roster = @competition.rosters.find(params[:id])
    end

    before_action :require_signuppable, only: [:new, :create]
    before_action :require_any_team_permission, only: [:new, :create]
    before_action :require_team_permission, only: [:create]
    before_action :require_user_league_permission, only: [:index, :review, :approve]
    before_action :require_roster_permission, only: [:edit, :update, :destroy]
    before_action :require_roster_disbandable, only: [:destroy]

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
      @roster = @competition.rosters.new(new_roster_params)
      @roster.team = Team.find(params[:team_id])

      if @roster.save
        redirect_to league_path(@competition)
      else
        render :new
      end
    end

    def show
      @comment = CompetitionRosterComment.new
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
      if @roster.update(approve_roster_params.merge(approved: true))
        redirect_to league_roster_path(@competition, @roster)
      else
        render :review
      end
    end

    def destroy
      if @roster.disband
        redirect_to league_path(@competition)
      else
        render :edit
      end
    end

    private

    def new_roster_params
      params.require(:competition_roster).permit(:name, :description, :division_id, player_ids: [])
    end

    def roster_params
      param = params.require(:competition_roster)

      if user_can_edit_league?
        param.permit(:name, :description, :disbanded, :ranking, :division_id)
      else
        param.permit(:description)
      end
    end

    def approve_roster_params
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

    def require_team_permission
      team = Team.find(params[:team_id])

      redirect_to league_path(@competition) unless user_can_edit_roster?(team: team)
    end

    def require_roster_permission
      redirect_to league_roster_path(@competition, @roster) unless user_can_edit_roster?
    end

    def require_roster_disbandable
      redirect_to league_roster_path(@competition, @roster) unless user_can_disband_roster?
    end
  end
end
