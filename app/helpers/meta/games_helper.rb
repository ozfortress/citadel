module Meta
  module GamesHelper
    def game_select
      ::Game.all.collect { |game| [game.name, game.id] }
    end
  end
end
