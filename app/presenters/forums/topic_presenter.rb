module Forums
  class TopicPresenter < ActionPresenter::Base
    presents :topic

    def link
      link_to(to_s, forums_topic_path(topic))
    end

    def path
      PATH_SEP.html_safe + safe_join(path_topics, PATH_SEP)
    end

    def to_s
      topic.name
    end

    private

    def path_topics
      present_collection(topic.ancestors).map(&:link)
    end
  end
end
