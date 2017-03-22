module API
  module V1
    class TeamsController < APIController
      def show
        @team = Team.find(params[:id])

        render json: @team, serializer: TeamSerializer, include: ['*', 'teams.users']
      end
    end
  end
end
