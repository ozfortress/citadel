module LeaguesHelper
  include LeaguePermissions

  def games
    @games ||= Game.all.select { |game| !game.leagues.not_hidden.empty? }
  end
end
