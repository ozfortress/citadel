module Meta
  module GamesHelper
    def games
      ::Game.all
    end

    def game_select
      ::Game.all.collect { |game| [game.name, game.id] }
    end
  end
end
