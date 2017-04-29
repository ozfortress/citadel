module LeaguesHelper
  include LeaguePermissions

  def games
    @games ||= Game.all.reject { |game| game.leagues.not_hidden.empty? }
  end
end
