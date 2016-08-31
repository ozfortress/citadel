module Forums
  class TopicsController < ApplicationController
    include Permissions

    before_action except: [:new, :create] { @topic = Topic.find(params[:id]) }
    before_action :require_forums_permission, except: :show

    def new
      @topic = Topic.new
      @topic.parent_topic = Topic.find(params[:parent_topic]) if params[:parent_topic]
    end

    def create
      @topic = Topic.new(topic_params.merge(created_by: current_user))

      if @topic.save
        redirect_to forums_topic_path(@topic)
      else
        @parent_topic = @topic.parent_topic
        render :new
      end
    end

    def show
      @topic = Topic.find(params[:id])
      @subtopics = @topic.child_topics
      @threads = @topic.threads
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

    def destroy
      if @topic.destroy
        redirect_to topic_parent_path(@topic)
      else
        render :edit
      end
    end

    private

    def topic_parent_path(topic)
      if topic.parent_topic
        forums_topic_path(topic.parent_topic)
      else
        forums_path
      end
    end

    def topic_params
      params.require(:forums_topic).permit(:name, :parent_topic_id)
    end

    def require_forums_permission
      redirect_back(fallback_location: forums_path) unless user_can_manage_forums?
    end
  end
end
