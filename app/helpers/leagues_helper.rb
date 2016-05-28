module LeaguesHelper
  include LeaguePermissions

  def games
    @games ||= Game.all.select { |game| !game.public_competitions.empty? }
  end
end
