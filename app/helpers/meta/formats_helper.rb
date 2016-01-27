module Meta
  module FormatsHelper
    def formats
      ::Format.all
    end

    def game_select
      ::Game.all.collect { |g| [g.name, g.id] }
    end
  end
end
