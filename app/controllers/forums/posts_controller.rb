module Forums
  class PostsController < ApplicationController
    include Forums::ThreadsCommon
    include Forums::Permissions

    before_action only: [:create] { @thread = Forums::Thread.find(params[:thread_id]) }
    before_action except: [:create] do
      @post = Post.find(params[:id])
      @thread = @post.thread
    end
    before_action :require_can_view_thread
    before_action :require_can_create_post, only: :create
    before_action :require_can_edit_post, only: [:edit, :update]
    before_action :require_can_manage_thread, only: :destroy

    def create
      @post = Posts::CreationService.call(current_user, @thread, post_params)

      if @post.persisted?
        redirect_to path_for(@post)
      else
        threads_show
        render 'forums/threads/show'
      end
    end

    def edits
      @edits = @post.edits.includes(:created_by).paginate(page: params[:page])
    end

    def edit
    end

    def update
      Posts::EditingService.call(current_user, @post, post_params)

      if !@post.changed?
        redirect_to path_for(@post)
      else
        render :edit
      end
    end

    def destroy
      if @post.destroy
        path = if @post.previous_post
                 path_for(@post.previous_post)
               else
                 forums_thread_path(@thread)
               end

        redirect_to path
      else
        render :edit
      end
    end

    private

    def path_for(post)
      page = Post.page_of(post)

      forums_thread_path(post.thread, page: page, anchor: "post_#{post.id}")
    end

    def post_params
      params.require(:forums_post).permit(:content)
    end

    def require_can_view_thread
      redirect_back(fallback_location: forums_path) unless user_can_view_thread?(@thread)
    end

    def require_can_manage_thread
      redirect_back(fallback_location: forums_path) unless user_can_manage_thread?(@thread)
    end

    def require_can_create_post
      redirect_back(fallback_location: forums_path) unless user_can_create_post?
    end

    def require_can_edit_post
      redirect_back(fallback_location: forums_path) unless user_can_edit_post?
    end
  end
end
