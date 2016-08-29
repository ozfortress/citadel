module Forums
  class TopicsController < ApplicationController
    def show
      @topic = Topic.find(params[:id])
      @subtopics = @topic.child_topics
      @threads = @topic.threads
    end
  end
end
