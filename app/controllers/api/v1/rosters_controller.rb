module API
  module V1
    class RostersController < APIController
      def show
        @roster = League::Roster.find(params[:id])

        render json: @roster, serializer: V1::Leagues::RosterSerializer
      end
    end
  end
end
