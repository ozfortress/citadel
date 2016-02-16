module Meta
  module GamesHelper
    def games
      ::Game.all
    end

    def game_select
      ::Game.all.collect { |g| [g.name, g.id] }
    end
  end
end
