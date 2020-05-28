module Forums
  class TopicPresenter < BasePresenter
    presents :topic

    def link
      link_to(to_s, forums_topic_path(topic))
    end

    def path
      html_escape(PATH_SEP) + safe_join(path_topics, PATH_SEP)
    end

    def breadcrumbs
      crumbs = []
      path_topics.each { |path| crumbs << content_tag(:li, path, class: 'breadcrumb-item') }
      safe_join(crumbs, '')
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
