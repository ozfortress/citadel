class User
  class CommentPresenter < BasePresenter
    presents :comment

    def created_at
      comment.created_at.strftime('%c')
    end

    def deleted_at
      comment.deleted_at.strftime('%c')
    end

    def created_by
      @created_by ||= present(comment.created_by)
    end

    def deleted_by
      @deleted_by ||= present(comment.deleted_by)
    end

    def content
      # rubocop:disable Rails/OutputSafety
      comment.content_render_cache.html_safe
      # rubocop:enable Rails/OutputSafety
    end

    def quote
      header = "#{created_by.name} wrote:"
      text = comment.content.split("\n").map { |line| "> #{line}" }.join("\n")

      [header, text].join("\n")
    end
  end
end
