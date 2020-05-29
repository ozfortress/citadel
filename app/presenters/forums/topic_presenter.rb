module Forums
  class TopicPresenter < BasePresenter
    presents :topic

    def link
      link_to(to_s, forums_topic_path(topic))
    end

    def breadcrumbs
      crumbs = path_topics.map { |path| content_tag(:li, path, class: 'breadcrumb-item') }
      crumbs << content_tag(:li, topic.name, class: 'breadcrumb-item active')
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
