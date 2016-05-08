module Leagues
  class MatchesController < ApplicationController
    include MatchPermissions

    before_action { @competition = Competition.find(params[:league_id]) }
    before_action except: [:index, :new, :create] do
      @match = @competition.matches.find(params[:id])
    end

    before_action :require_user_league_permission, only: [:new, :create, :edit, :update, :destroy]
    before_action :require_user_either_teams, only: [:comms, :scores, :confirm]
    before_action :require_user_can_report_scores, only: [:scores]

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
      @comm = @match.comms.new(comm_params.merge(user: current_user))

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
              .permit(:status, sets_attributes: [:id, :home_team_score, :away_team_score])
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

    def comm_params
      params.require(:competition_comm).permit(:content)
    end

    def require_user_can_report_scores
      unless user_can_edit_league? || (user_can_submit_team_score? &&
                                       @competition.matches_submittable)
        redirect_to league_match_path(@competition, @match)
      end
    end

    def require_user_league_permission
      redirect_to league_path(@competition) unless user_can_edit_league?
    end

    def require_user_either_teams
      redirect_to league_match_path(@competition, @match) unless user_can_either_teams?
    end
  end
end
