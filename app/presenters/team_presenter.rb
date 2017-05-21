class TeamPresenter < BasePresenter
  presents :team

  def to_s
    team.name
  end

  def link(label = nil)
    label ||= team.name
    link_to(label, team_path(team))
  end

  def description
    # rubocop:disable Rails/OutputSafety
    team.description_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
