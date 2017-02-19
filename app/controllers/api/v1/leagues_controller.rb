module API
  module V1
    class LeaguesController < APIController
      before_action only: [:show] { @league = League.find(params[:id]) }
      before_action :require_visible, only: :show

      def show
        render json: @league, serializer: LeagueSerializer
      end

      private

      def require_visible
        render_404 if @league.hidden?
      end
    end
  end
end
