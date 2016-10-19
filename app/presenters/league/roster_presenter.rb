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
      link_to(label, roster_path(roster), options, &block)
    end

    def title
      if league.signuppable?
        signup_title
      else
        active_title
      end
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

    def league_p
      @league_p ||= present(league)
    end

    private

    def signup_title
      html_escape("#{roster.name} signed up on #{created_at_s} to ") + league_p.link
    end

    def active_title
      html_escape("#{roster.name} playing in #{roster.division.name} for ") + league_p.link
    end
  end
end
