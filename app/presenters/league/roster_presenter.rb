class League
  class RosterPresenter < BasePresenter
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
      link_to(label, team_path(roster.team_id), options, &block)
    end

    def title
      title = if league.completed?
                past_title
              elsif league.signuppable? || !roster.approved?
                signup_title
              else
                active_title
              end
      title += disbanded_tag if roster.disbanded?
      title
    end

    def listing
      listing = link
      listing += disbanded_tag if roster.disbanded?
      listing
    end

    def user_listing
      if league.completed?
        safe_join(['Played in ', league_p.link, ' with ', link])
      elsif league.signuppable? || !roster.approved?
        safe_join(['Signed up to ', league_p.link, ' with ', link])
      else
        safe_join(['Playing in ', league_p.link, ' with ', link])
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

    def description
      # rubocop:disable Rails/OutputSafety
      roster.description_render_cache.html_safe
      # rubocop:enable Rails/OutputSafety
    end

    def notice
      # rubocop:disable Rails/OutputSafety
      roster.notice_render_cache.html_safe
      # rubocop:enable Rails/OutputSafety
    end

    def bracket_data
      { name: html_escape(roster.name), id: roster.id, link: team_path(roster.team_id) }
    end

    def to_s
      roster.name
    end

    private

    def disbanded_tag
      safe_join([' ', content_tag(:span, 'Disbanded', class: 'label label-danger')])
    end

    def signup_title
      html_escape("#{roster.name} signed up on #{created_at_s} to ") + league_p.link
    end

    def active_title
      text = "Active roster for #{roster.name} playing in #{roster.division.name} for "
      html_escape(text) + league_p.link
    end

    def past_title
      text = "#{roster.name} played in #{roster.division.name} for "
      html_escape(text) + league_p.link
    end
  end
end
