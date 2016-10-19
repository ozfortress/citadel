module Leagues
  module Matches
    class CommsController < ApplicationController
      include MatchPermissions

      before_action only: :create do
        @match = League::Match.find(params[:match_id])
        @league = @match.league
      end

      before_action :require_user_can_comm

      def create
        @comm = League::Match::Comm.new(comm_params.merge(user: current_user, match: @match))

        if @comm.save
          redirect_to match_path(@match)
        else
          render 'leagues/matches/show'
        end
      end

      private

      def comm_params
        params.require(:comm).permit(:content)
      end

      def require_user_can_comm
        redirect_to match_path(@match) unless user_can_comm?
      end
    end
  end
end
