module Leagues
  class MatchesController < ApplicationController
    include MatchPermissions

    before_action { @competition = Competition.find(params[:league_id]) }
    before_action except: [:index, :new, :create] do
      @match = @competition.matches.find(params[:id])
    end

    before_action :require_user_league_permission, except: [:show]
    before_action :require_user_comms, only: [:comms]

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

    private

    def match_params
      params.require(:competition_match).permit(:home_team_id, :away_team_id,
                                                sets_attributes: [:id, :_destroy, :map_id])
    end

    def comm_params
      params.require(:competition_comm).permit(:content)
    end

    def require_user_league_permission
      redirect_to league_path(@competition) unless user_can_edit_league?
    end

    def require_user_comms
      redirect_to league_match_path(@competition, @match) unless user_can_comms?
    end
  end
end
