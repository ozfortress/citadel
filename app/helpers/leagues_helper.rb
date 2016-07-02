module LeaguesHelper
  include LeaguePermissions

  def games
    @games ||= Game.all.select { |game| !game.competitions.not_hidden.empty? }
  end
end
