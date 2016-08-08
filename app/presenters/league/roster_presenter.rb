class League
  class RosterPresenter < ActionPresenter::Base
    presents :roster

    delegate :id, to: :roster
    delegate :name, to: :roster
    delegate :league, to: :roster
    delegate :division, to: :roster
    delegate :approved?, to: :roster
    delegate :disbanded?, to: :roster
    delegate :points, to: :roster
    delegate :==, to: :roster

    def link(label = nil, options = {}, &block)
      label ||= name
      link_to(label, league_roster_path(league, roster), options, &block)
    end

    def score_s
      if disbanded?
        'Disbanded'
      else
        "Points: #{points}"
      end
    end

    def created_at_s
      roster.created_at.strftime('%c')
    end
  end
end
