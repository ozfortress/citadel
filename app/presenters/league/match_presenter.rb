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
      link_to(label, league_match_path(league, match), options, &block)
    end

    def players
      home_players = object.home_team.player_users
      away_players = object.away_team.player_users
      [home_players.length, away_players.length].max.times do |i|
        home_player = present(home_players[i]) if i < home_players.length
        away_player = present(away_players[i]) if i < away_players.length

        yield(home_player, away_player)
      end
    end

    private

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
