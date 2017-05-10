class MapPresenter < BasePresenter
  presents :map

  def game
    present(map.game)
  end

  def link(options = {})
    link_to map.name, meta_map_path(map), options
  end

  def description
    # rubocop:disable Rails/OutputSafety
    map.description_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
