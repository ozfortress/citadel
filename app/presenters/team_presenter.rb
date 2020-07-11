class TeamPresenter < BasePresenter
  presents :team

  def to_s
    team.name
  end

  def avatar_tag(options = {})
    image_tag(team.avatar.thumb.url, options)
  end

  def link(label = nil, options = {})
    label ||= team.name
    link_to(label, team_path(team), options)
  end

  def description
    # rubocop:disable Rails/OutputSafety
    team.description_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def notice
    # rubocop:disable Rails/OutputSafety
    team.notice_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def summary
    active_rosters = team.rosters.active.for_incomplete_league.to_a

    if active_rosters.empty?
      ''
    elsif active_rosters.length == 1
      single_roster_summary(active_rosters)
    elsif active_rosters.length < 4
      roster_list_summary(active_rosters)
    else
      "Playing in #{active_rosters.length} leagues"
    end
  end

  private

  def single_roster_summary(active_rosters)
    # TODO: Link to roster on league page
    safe_join([
                "Playing in #{active_rosters[0].division.name} for",
                present(active_rosters[0].league).link,
              ], ' ')
  end

  def roster_list_summary(active_rosters)
    parts = ['Playing in']
    parts.concat(active_rosters.map { |roster| present(roster.league).link })
    safe_join(parts, ' ')
  end
end
