module Forums
  class ThreadsController < ApplicationController
    include Forums::Permissions

    before_action only: [:new, :create] do
      @topic = Forums::Topic.find(params[:topic]) if params[:topic]
    end
    before_action except: [:new, :create] { @thread = Forums::Thread.find(params[:id]) }

    before_action :require_can_create_thread, only: [:new, :create]
    before_action :require_can_view_thread, only: :show
    before_action :require_can_edit_thread, only: [:edit, :update]
    before_action :require_can_manage_thread, only: [:destroy]

    def new
      @thread = Forums::Thread.new(topic: @topic)
    end

    def create
      params = new_thread_params.merge(topic: @topic, created_by: current_user)
      @thread = Forums::Thread.new(params)

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

    def new_thread_params
      if user_can_manage_topic?
        params.require(:forums_thread).permit(:topic_id, :title, :locked, :pinned, :hidden)
      else
        params.require(:forums_thread).permit(:topic_id, :title)
      end
    end

    def thread_params
      if user_can_manage_thread?
        params.require(:forums_thread).permit(:topic_id, :title, :locked, :pinned, :hidden)
      else
        params.require(:forums_thread).permit(:topic_id, :title)
      end
    end

    def require_can_create_thread
      redirect_back(fallback_location: forums_path) unless user_can_create_thread?
    end

    def require_can_manage_thread
      redirect_back(fallback_location: forums_path) unless user_can_manage_thread?
    end

    def require_can_edit_thread
      redirect_back(fallback_location: forums_path) unless user_can_edit_thread?
    end

    def require_can_view_thread
      redirect_back(fallback_location: forums_path) unless user_can_view_thread?
    end
  end
end
