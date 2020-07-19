module Forums
  class TopicPresenter < BasePresenter
    presents :topic

    def link
      link_to(to_s, forums_topic_path(topic))
    end

    def breadcrumbs
      crumbs = path_topics.map { |path| content_tag(:li, path, class: 'breadcrumb-item') }
      safe_join(crumbs, '')
    end

    def description
      # rubocop:disable Rails/OutputSafety
      topic.description_render_cache.html_safe
      # rubocop:enable Rails/OutputSafety
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
