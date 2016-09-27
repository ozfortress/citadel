module Leagues
  class RostersController < ApplicationController
    include RosterPermissions

    before_action { @league = League.find(params[:league_id]) }
    before_action except: [:index, :new, :create] do
      @roster = @league.rosters.find(params[:id])
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
      @roster = @league.divisions.first.rosters.new

      if params.key?(:team_id)
        @team = Team.find(params[:team_id])
        redirect_to league_path(@league) if @team.entered?(@league)

        @roster.team = @team
        @roster.name = @team.name
      end
    end

    def create
      @roster = @league.rosters.new(new_roster_params)
      @roster.team = Team.find(params[:team_id])

      if @roster.save
        redirect_to league_path(@league)
      else
        render :new
      end
    end

    def show
      @comment = League::Roster::Comment.new
      @matches = @roster.matches.order(:created_at).includes(:home_team, :away_team)
    end

    def edit
    end

    def update
      if @roster.update(roster_params)
        redirect_to league_roster_path(@league, @roster)
      else
        render :edit
      end
    end

    def review
    end

    def approve
      if @roster.update(approve_roster_params.merge(approved: true))
        redirect_to league_roster_path(@league, @roster)
      else
        render :review
      end
    end

    def destroy
      if @roster.disband
        redirect_to league_path(@league)
      else
        render :edit
      end
    end

    private

    def schedule_params
      @params_schedule_data ||= params[:roster].delete(:schedule_data)
      @params_schedule_data.permit! if @params_schedule_data
    end

    def new_roster_params
      param = params.require(:roster).permit(:name, :description, :division_id, player_ids: [])

      whitelist_schedule_params(param)
    end

    def roster_params
      roster = params.require(:roster)

      params = if user_can_edit_league?
                 roster.permit(:name, :description, :disbanded, :ranking,
                               :seeding, :division_id)
               else
                 roster.permit(:description)
               end

      params = whitelist_schedule_params(params) if @league.schedule_locked?

      params
    end

    def whitelist_schedule_params(params)
      params.tap do |whitelisted|
        whitelisted[:schedule_data] = schedule_params
      end
    end

    def approve_roster_params
      params.require(:roster).permit(:name, :division_id, :seeding)
    end

    def require_signuppable
      redirect_to league_path(@league) unless @league.signuppable?
    end

    def require_any_team_permission
      redirect_to league_path(@league) unless user_signed_in? &&
                                              current_user.can_any?(:edit, :team)
    end

    def require_user_league_permission
      redirect_to league_path(@league) unless user_can_edit_league?
    end

    def require_team_permission
      team = Team.find(params[:team_id])

      redirect_to league_path(@league) unless user_can_edit_roster?(team: team)
    end

    def require_roster_permission
      redirect_to league_roster_path(@league, @roster) unless user_can_edit_roster?
    end

    def require_roster_disbandable
      redirect_to league_roster_path(@league, @roster) unless user_can_disband_roster?
    end
  end
end
