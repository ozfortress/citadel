module Users
  class CommentsController < ApplicationController
    include ::UsersPermissions

    before_action { @user = User.find(params[:user_id]) }
    before_action :require_user_permissions

    def create
      params = comment_params.merge(created_by: current_user)
      @comment = @user.comments.create(params)

      redirect_to user_path(@user)
    end

    private

    def comment_params
      params.require(:comment).permit(:content)
    end

    def require_user_permissions
      redirect_back(fallback_location: root_path) unless user_can_edit_users?
    end
  end
end
