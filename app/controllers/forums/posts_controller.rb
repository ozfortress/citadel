module Forums
  class PostsController < ApplicationController
    include Forums::Permissions

    before_action only: [:create] { @thread = Forums::Thread.find(params[:thread_id]) }
    before_action except: [:create] { @post = Post.find(params[:id]) }
    before_action :require_can_view_thread
    before_action :require_can_create_post, only: :create
    before_action :require_can_edit_post, only: [:edit, :update]
    before_action :require_can_manage_thread, only: :destroy

    def create
      @post = Posts::CreationService.call(current_user, @thread, post_params)

      if @post.persisted?
        redirect_to forums_thread_path(@thread)
      else
        @posts = @thread.posts
        render 'forums/threads/show'
      end
    end

    def edit
    end

    def update
      if @post.update(post_params)
        redirect_to forums_thread_path(@post.thread)
      else
        render :edit
      end
    end

    def destroy
      if @post.destroy
        redirect_to forums_thread_path(@post.thread)
      else
        render :edit
      end
    end

    private

    def post_params
      params.require(:forums_post).permit(:content)
    end

    def require_can_view_thread
      thread = @thread || @post.thread
      redirect_back(fallback_location: forums_path) unless user_can_view_thread?(thread)
    end

    def require_can_manage_thread
      redirect_back(fallback_location: forums_path) unless user_can_manage_thread?(@post.thread)
    end

    def require_can_create_post
      redirect_back(fallback_location: forums_path) unless user_can_create_post?
    end

    def require_can_edit_post
      redirect_back(fallback_location: forums_path) unless user_can_edit_post?
    end
  end
end
