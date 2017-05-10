class FormatPresenter < BasePresenter
  presents :format

  def game
    present(format.game)
  end

  def link(options = {})
    link_to format.name, meta_format_path(format), options
  end

  def description
    # rubocop:disable Rails/OutputSafety
    format.description_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
