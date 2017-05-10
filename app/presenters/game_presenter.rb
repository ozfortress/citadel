class GamePresenter < BasePresenter
  presents :game

  def link(options = {})
    link_to game.name, meta_game_path(game), options
  end
end
