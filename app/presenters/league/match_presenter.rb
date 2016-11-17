class League
  class MatchPresenter < ActionPresenter::Base
    presents :match

    delegate :id, to: :match
    delegate :round, to: :match
    delegate :home_team, to: :match
    delegate :away_team, to: :match
    delegate :league, to: :match
    delegate :bye?, to: :match

    def to_s
      match_s(&:name)
    end

    def title
      match_s { |team| present(team).link }.html_safe
    end

    def link(label = nil, options = {}, &block)
      label ||= to_s
      link_to(label, match_path(match), options, &block)
    end

    def players
      home_players = object.home_team.users
      away_players = object.away_team.users
      [home_players.length, away_players.length].max.times do |i|
        home_player = home_players[i] if i < home_players.length
        away_player = away_players[i] if i < away_players.length

        yield(home_player, away_player)
      end
    end

    def results
      return unless match.confirmed?

      if match.bye?
        'BYE'
      elsif match.no_forfeit?
        score_results
      else
        forfeit_results
      end
    end

    private

    def score_results
      scores = match.rounds.map { |round| "#{round.home_team_score}:#{round.away_team_score}" }

      "| #{scores.join(' | ')} |"
    end

    def forfeit_results
      case match.forfeit_by
      when 'home_team_forfeit'
        "#{home_team.name} forfeit"
      when 'away_team_forfeit'
        "#{away_team.name} forfeit"
      else
        match.forfeit_by.to_s.humanize
      end
    end

    def match_s
      round_s + if bye?
                  "#{yield home_team} BYE"
                else
                  "#{yield home_team} vs #{yield away_team}"
                end
    end

    def round_s
      if round
        "##{round} "
      else
        ''
      end
    end
  end
end
