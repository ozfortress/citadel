module Forums
  class ThreadsController < ApplicationController
    include Permissions

    before_action except: [:new, :create] { @thread = Forums::Thread.find(params[:id]) }
    before_action :require_forums_permission, except: :show

    def new
      @thread = Forums::Thread.new
      @thread.topic = Topic.find(params[:topic]) if params[:topic]
    end

    def create
      @thread = Forums::Thread.new(thread_params.merge(created_by: current_user))

      if @thread.save
        redirect_to forums_thread_path(@thread)
      else
        render :new
      end
    end

    def show
      @thread = Forums::Thread.find(params[:id])
      @posts = @thread.posts
      @post = Post.new
    end

    def edit
    end

    def update
      if @thread.update(thread_params)
        redirect_to forums_thread_path(@thread)
      else
        render :edit
      end
    end

    def destroy
      if @thread.destroy
        redirect_to thread_parent_path(@thread)
      else
        render :edit
      end
    end

    private

    def thread_parent_path(thread)
      if thread.topic
        forums_topic_path(thread.topic)
      else
        forums_path
      end
    end

    def thread_params
      params.require(:forums_thread).permit(:title, :topic_id)
    end

    def require_forums_permission
      redirect_back(fallback_location: forums_path) unless user_can_manage_forums?
    end
  end
end
