module API
  module V1
    class UsersController < APIController
      def show
        @user = User.find(params[:id])

        render json: @user, serializer: UserSerializer
      end
    end
  end
end
