module Forums
  class PostPresenter < BasePresenter
    presents :post

    def created_at
      post.created_at.strftime('%c')
    end

    def content
      # rubocop:disable Rails/OutputSafety
      post.content_render_cache.html_safe
      # rubocop:enable Rails/OutputSafety
    end
  end
end
