class LeaguePresenter < ActionPresenter::Base
  presents :league

  def link
    link_to league.name, league_path(league)
  end
end
