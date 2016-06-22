module Leagues
  class MatchesController < ApplicationController
    include MatchPermissions

    before_action { @competition = Competition.find(params[:league_id]) }
    before_action except: [:index, :new, :create, :generate, :create_round] do
      @match = @competition.matches.find(params[:id])
    end

    before_action :require_user_league_permission, only: [:new, :create, :generate, :create_round,
                                                          :edit, :update, :destroy]
    before_action :require_user_either_teams, only: [:scores, :confirm]
    before_action :require_user_can_report_scores, only: [:scores, :forfeit]
    before_action :require_match_not_bye, only: [:scores, :confirm, :forfeit]
    before_action :require_user_can_comm, only: [:comms]

    def index
    end

    def new
      @match = CompetitionMatch.new
      @match.sets.new
    end

    def create
      @match = CompetitionMatch.new(match_params)

      if @match.save
        redirect_to league_match_path(@competition, @match)
      else
        render :new
      end
    end

    def generate
      @match = CompetitionMatch.new
      @match.sets.new
      @kind = :swiss
    end

    def create_round
      params = create_round_params
      division = @competition.divisions.find(params.delete(:division_id))
      @kind = params.delete(:generate_kind)
      if division.seed_round_with(@kind, params)
        redirect_to league_matches_path(@competition)
      else
        @match = CompetitionMatch.new(params)
        render :generate
      end
    end

    def show
      @comm = CompetitionComm.new(match: @match)
    end

    def edit
    end

    def update
      if @match.update(match_params)
        redirect_to league_match_path(@competition, @match)
      else
        render :edit
      end
    end

    def comms
      @comm = CompetitionComm.new(comm_params.merge(user: current_user, match: @match))

      if @comm.save
        redirect_to league_match_path(@competition, @match)
      else
        render :show
      end
    end

    def scores
      if @match.update(report_scores_params)
        redirect_to league_match_path(@competition, @match)
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
        redirect_to league_match_path(@competition, @match)
      end
    end

    def forfeit
      @match.forfeit(user_can_home_team?)
      show
      render :show
    end

    def destroy
      if @match.destroy
        redirect_to league_path(@competition)
      else
        render :edit
      end
    end

    private

    def report_scores_params
      if user_can_edit_league?
        params.require(:competition_match)
              .permit(:status, :forfeit_by, sets_attributes: [:id, :home_team_score,
                                                              :away_team_score])
      elsif user_can_either_teams?
        report_scores_by_team_params
      end
    end

    def report_scores_by_team_params
      attrs = params.require(:competition_match)
                    .permit(sets_attributes: [:id, :home_team_score, :away_team_score])

      attrs[:status] = if user_can_home_team?
                         :submitted_by_home_team
                       else
                         :submitted_by_away_team
                       end

      attrs
    end

    def match_params
      params.require(:competition_match).permit(:home_team_id, :away_team_id,
                                                sets_attributes: [:id, :_destroy, :map_id])
    end

    def create_round_params
      params.require(:competition_match).permit(:division_id, :generate_kind,
                                                sets_attributes: [:id, :_destroy, :map_id])
    end

    def comm_params
      params.require(:competition_comm).permit(:content)
    end

    def require_user_can_report_scores
      redirect_to league_match_path(@competition, @match) unless user_can_submit_team_score?
    end

    def require_user_league_permission
      redirect_to league_path(@competition) unless user_can_edit_league?
    end

    def require_user_either_teams
      redirect_to league_match_path(@competition, @match) unless user_can_either_teams?
    end

    def require_match_not_bye
      redirect_to league_match_path(@competition, @match) if @match.bye?
    end

    def require_user_can_comm
      redirect_to league_match_path(@competition, @match) unless user_can_comm?
    end
  end
end
