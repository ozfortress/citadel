module Forums
  class PostsController < ApplicationController
    include Permissions

    before_action only: [:create] { @thread = Forums::Thread.find(params[:thread_id]) }
    before_action except: [:create] { @post = Post.find(params[:id]) }
    before_action :require_forums_permission

    def create
      @post = Post.new(post_params.merge(created_by: current_user, thread: @thread))

      if @post.save
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

    def require_forums_permission
      redirect_back(fallback_location: forums_path) unless user_can_manage_forums?
    end
  end
end
