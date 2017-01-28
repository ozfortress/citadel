module Forums
  class ThreadsController < ApplicationController
    include Forums::Permissions

    before_action only: [:new, :create] do
      @topic = Forums::Topic.find(params[:topic]) if params[:topic]
    end
    before_action except: [:new, :create] { @thread = Forums::Thread.find(params[:id]) }

    before_action :require_can_create_thread, only: [:new, :create]
    before_action :require_login, only: :toggle_subscription
    before_action :require_can_view_thread, only: [:show, :toggle_subscription]
    before_action :require_can_edit_thread, only: [:edit, :update]
    before_action :require_can_manage_thread, only: [:destroy]

    def new
      @thread = Forums::Thread.new(topic: @topic)
      @post = @thread.posts.new
    end

    def create
      @thread = Threads::CreationService.call(current_user, @topic, new_thread_params,
                                              new_thread_post_params)
      @post = @thread.posts.first

      if @thread.persisted?
        redirect_to forums_thread_path(@thread)
      else
        render :new
      end
    end

    def show
      @thread = Forums::Thread.find(params[:id])
      @posts = @thread.posts.includes(:thread, :created_by).paginate(page: params[:page])
      @post = Post.new
    end

    def toggle_subscription
      subscription = current_user.forums_subscriptions.where(thread: @thread)
      if subscription.exists?
        subscription.destroy_all
      else
        subscription.create!
      end
      redirect_to forums_thread_path(@thread)
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

    def new_thread_post_params
      params.require(:forums_thread).require(:forums_post).permit(:content)
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
