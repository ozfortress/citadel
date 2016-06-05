class CompetitionRosterPresenter < ActionPresenter::Base
  presents :competition_roster

  delegate :id, to: :competition_roster
  delegate :name, to: :competition_roster
  delegate :competition, to: :competition_roster
  delegate :division, to: :competition_roster
  delegate :approved?, to: :competition_roster
  delegate :disbanded?, to: :competition_roster
  delegate :points, to: :competition_roster
  delegate :==, to: :competition_roster

  def link(label = nil, options = {}, &block)
    label ||= name
    link_to(label, league_roster_path(competition, competition_roster), options, &block)
  end

  def score_s
    if disbanded?
      'Disbanded'
    else
      "Points: #{points}"
    end
  end

  def created_at_s
    competition_roster.created_at.strftime('%c')
  end
end
