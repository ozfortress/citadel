class CompetitionMatchPresenter < ActionPresenter::Base
  presents :competition_match

  delegate :id, to: :competition_match
  delegate :home_team, to: :competition_match
  delegate :away_team, to: :competition_match
  delegate :competition, to: :competition_match
  delegate :bye?, to: :competition_match

  def to_s
    if bye?
      "#{home_team.name} BYE"
    else
      "#{home_team.name} vs #{away_team.name}"
    end
  end

  def title
    if bye?
      present(home_team).link + " BYE"
    else
      present(home_team).link + " vs " + present(away_team).link
    end
  end

  def link(label = nil, options = {}, &block)
    label ||= to_s
    link_to(label, league_match_path(competition, competition_match), options, &block)
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
end
