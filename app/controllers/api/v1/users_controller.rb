module API
  module V1
    class UsersController < APIController
      def show
        @user = User.find(params[:id])

        render json: @user, serializer: UserSerializer
      end

      def steam_id
        @user = User.find_by!(steam_id: params[:id])

        render json: @user, serializer: UserSerializer
      end
    end
  end
end
