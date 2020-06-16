module Forums
  class TopicsController < ApplicationController
    include Forums::Permissions

    before_action only: [:new, :create] do
      @parent_topic = Topic.find(params[:parent]) if params[:parent]
    end

    before_action except: [:new, :create] do
      @topic = Topic.find(params[:id])
    end

    before_action :require_can_manage_parent, only: [:new, :create]
    before_action :require_login, only: :toggle_subscription
    before_action :require_can_view, only: [:show, :toggle_subscription]
    before_action :require_isolated, only: :unisolate
    before_action :require_not_isolated, only: :isolate
    before_action :require_can_manage, only: [:edit, :update, :isolate, :unisolate, :destroy]

    def new
      @topic = Forums::Topic.new(parent: @parent_topic)
    end

    def create
      params = topic_params.merge(parent: @parent_topic, created_by: current_user)
      @topic = Forums::Topic.new(params)

      if @topic.save
        redirect_to forums_topic_path(@topic)
      else
        @parent_topic = @topic.parent
        render :new
      end
    end

    def show
      @subtopics = @topic.children
      @threads = @topic.threads.ordered

      unless user_can_manage_topic?
        @subtopics = @subtopics.visible
        @threads   = @threads.visible.or(@threads.where(created_by: current_user))
      end

      @threads = @threads.includes(:created_by).paginate(page: params[:page])
    end

    def toggle_subscription
      subscription = current_user.forums_subscriptions.where(topic: @topic)
      if subscription.exists?
        subscription.destroy_all
      else
        subscription.create!
      end
      redirect_to forums_topic_path(@topic)
    end

    def edit
    end

    def update
      if @topic.update(topic_params)
        redirect_to forums_topic_path(@topic)
      else
        render :edit
      end
    end

    def isolate
      if Topics::IsolationService.call(current_user, @topic)
        redirect_to forums_topic_path(@topic)
      else
        render :edit
      end
    end

    def unisolate
      if @topic.update(isolated: false)
        redirect_to forums_topic_path(@topic)
      else
        render :edit
      end
    end

    def destroy
      if @topic.destroy
        redirect_to topic_parent_path(@topic)
      else
        render :edit
      end
    end

    private

    def topic_parent_path(topic)
      if topic.parent
        forums_topic_path(topic.parent)
      else
        forums_path
      end
    end

    def topic_params
      params.require(:forums_topic).permit(:parent_id, :name, :locked, :pinned,
                                           :hidden, :default_locked, :default_hidden)
    end

    def require_can_manage_parent
      redirect_back(fallback_location: forums_path) unless user_can_manage_topic?(@parent_topic)
    end

    def require_can_view
      redirect_back(fallback_location: forums_path) unless user_can_view_topic?
    end

    def require_not_isolated
      redirect_back(fallback_location: forums_path) if @topic.isolated?
    end

    def require_isolated
      redirect_back(fallback_location: forums_path) unless @topic.isolated?
    end

    def require_can_manage
      redirect_back(fallback_location: forums_path) unless user_can_manage_topic?
    end
  end
end
