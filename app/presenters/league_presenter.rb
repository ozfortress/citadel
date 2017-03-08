class LeaguePresenter < ActionPresenter::Base
  presents :league

  def link
    link_to league.name, league_path(league)
  end

  def description
    # rubocop:disable Rails/OutputSafety
    league.description_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
