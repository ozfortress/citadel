class CompetitionMatchPresenter < ActionPresenter::Base
  presents :competition_match

  delegate :id, to: :competition_match
  delegate :home_team, to: :competition_match
  delegate :away_team, to: :competition_match
  delegate :competition, to: :competition_match

  def to_s
    "#{home_team.name} vs #{away_team.name}"
  end

  def link(label = nil, options = {}, &block)
    label ||= to_s
    link_to(label, league_match_path(competition, competition_match), options, &block)
  end
end
