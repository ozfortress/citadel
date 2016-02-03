module LeaguesHelper
  include LeaguePermissions

  def games
    Game.all
  end
end
