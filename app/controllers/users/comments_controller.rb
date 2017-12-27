module Users
  class CommentsController < ApplicationController
    include ::UsersPermissions

    before_action do
      @user = User.find(params[:user_id])
    end

    before_action only: [:edit, :update, :edits, :destroy, :restore] do
      @comment = @user.comments.find(params[:id])
    end

    before_action :require_user_permissions

    def create
      @comment = Comments::CreationService.call(current_user, @user, comment_params)

      redirect_to user_path(@user)
    end

    def edit
    end

    def update
      @comment = Comments::EditingService.call(current_user, @comment, comment_params)

      if @comment.valid?
        redirect_to user_path(@user)
      else
        render :edit
      end
    end

    def edits
      @edits = @comment.edits.includes(:created_by)
    end

    def destroy
      @comment.delete!(current_user)
      redirect_to user_path(@user)
    end

    def restore
      @comment.undelete!
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
