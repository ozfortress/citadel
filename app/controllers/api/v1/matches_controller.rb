module API
  module V1
    class MatchesController < APIController
      def show
        @match = League::Match.find(params[:id])

        render json: @match, serializer: Leagues::MatchSerializer,
               include: ['*', 'home_team.players', 'away_team.players']
      end
    end
  end
end
