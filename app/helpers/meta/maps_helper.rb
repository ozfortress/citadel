module Meta
  module MapsHelper
    include GamesHelper

    def maps
      ::Map.all
    end
  end
end
