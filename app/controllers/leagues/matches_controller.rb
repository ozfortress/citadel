module Leagues
  class MatchesController < ApplicationController
    include MatchPermissions

    before_action only: [:index, :new, :create, :generate, :create_round] do
      @league = League.find(params[:league_id])
    end
    before_action except: [:index, :new, :create, :generate, :create_round] do
      @match = League::Match.find(params[:id])
      @league = @match.league
    end

    before_action :require_user_league_permission, only: [:new, :create, :generate, :create_round,
                                                          :edit, :update, :destroy]
    before_action :require_user_either_teams, only: [:submit, :confirm]
    before_action :require_user_can_report_scores, only: [:submit, :forfeit]
    before_action :require_match_not_bye, only: [:submit, :confirm, :forfeit]

    def index
      @divisions = @league.divisions.includes(matches: [:away_team, :rounds, home_team: :division])
    end

    def new
      @match = League::Match.new
      @match.rounds.new
      @division = @league.divisions.first
    end

    def create
      @division = @league.divisions.find(params[:division_id])
      @match = Matches::CreationService.call(match_params)

      if @match.persisted?
        redirect_to match_path(@match)
      else
        @match.reset_results
        render :new
      end
    end

    def generate
      @match = League::Match.new
      @match.rounds.new
      @division = @league.divisions.first
      @kind = :swiss
    end

    def create_round
      params = create_round_params
      @kind     = params.delete(:generate_kind)
      @division = @league.divisions.find(params.delete(:division_id))
      @match    = Matches::GenerationService.call(@division, @kind, params)

      if @match.persisted?
        redirect_to league_matches_path(@league)
      else
        @match.reset_results
        render :generate
      end
    end

    def show
      @comm = League::Match::Comm.new(match: @match)
      @comms = @match.comms.order(:created_at).includes(:user)
    end

    def edit
    end

    def update
      if @match.update(match_params)
        redirect_to match_path(@match)
      else
        render :edit
      end
    end

    def submit
      if @match.update(report_scores_params)
        redirect_to match_path(@match)
      else
        @match.status = :pending
        show
        render :show
      end
    end

    def confirm
      if user_can_confirm_score? || user_can_edit_league?
        @match.confirm_scores(params[:confirm] == 'true')
        show
        render :show
      else
        redirect_to match_path(@match)
      end
    end

    def forfeit
      @match.forfeit(user_can_home_team?)
      show
      render :show
    end

    def destroy
      if @match.destroy
        redirect_to league_path(@league)
      else
        render :edit
      end
    end

    private

    def report_scores_params
      if user_can_edit_league?
        params.require(:match)
              .permit(:status, :forfeit_by,
                      rounds_attributes: [:id, :home_team_score, :away_team_score])
      elsif user_can_either_teams?
        report_scores_by_team_params
      end
    end

    def report_scores_by_team_params
      attrs = params.require(:match)
                    .permit(rounds_attributes: [:id, :home_team_score, :away_team_score])

      attrs[:status] = if user_can_home_team?
                         :submitted_by_home_team
                       else
                         :submitted_by_away_team
                       end

      attrs
    end

    def match_params
      params.require(:match).permit(:home_team_id, :away_team_id, :round, :notice,
                                    pick_bans_attributes: [:id, :_destroy, :kind, :team],
                                    rounds_attributes: [:id, :_destroy, :map_id])
    end

    def create_round_params
      params.require(:match).permit(:division_id, :generate_kind, :round, :notice,
                                    pick_bans_attributes: [:id, :_destroy, :kind, :team],
                                    rounds_attributes: [:id, :_destroy, :map_id])
    end

    def require_user_can_report_scores
      redirect_to match_path(@match) unless user_can_submit_team_score?
    end

    def require_user_league_permission
      redirect_to league_path(@league) unless user_can_edit_league?
    end

    def require_user_either_teams
      redirect_to match_path(@match) unless user_can_either_teams?
    end

    def require_match_not_bye
      redirect_to match_path(@match) if @match.bye?
    end
  end
end
