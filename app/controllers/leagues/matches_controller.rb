module Leagues
  class MatchesController < ApplicationController
    include LeaguePermissions

    before_action { @competition = Competition.find(params[:league_id]) }
    before_action except: [:index, :new, :create] do
      @match = @competition.matches.find(params[:id])
    end

    before_action :require_user_league_permission, except: [:show]

    def index
    end

    def new
      @match = CompetitionMatch.new
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

    private

    def match_params
      params.require(:competition_match).permit(:home_team_id, :away_team_id,
                                                sets_attributes: [:id, :_destroy, :map_id])
    end

    def require_user_league_permission
      redirect_to league_path(@competition) unless user_can_edit_league?
    end
  end
end
