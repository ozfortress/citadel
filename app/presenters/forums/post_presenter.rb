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

    def quote
      header = "#{post.created_by.name} wrote:"
      text = post.content.split("\n").map { |line| "> #{line}" }.join("\n")

      [header, text].join("\n")
    end

    def edit_path
      if post.first_post?
        edit_forums_thread_path(post.thread)
      else
        edit_forums_post_path(post)
      end
    end
  end
end
