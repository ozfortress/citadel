module LeaguesHelper
  include LeaguePermissions

  def games
    @games ||= Game.all.select { |game| !game.competitions.running.empty? }
  end
end
