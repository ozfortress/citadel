module Meta
  module GamesHelper
    def games
      ::Game.all
    end
  end
end
