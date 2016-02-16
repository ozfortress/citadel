module Meta
  module FormatsHelper
    include GamesHelper

    def formats
      ::Format.all
    end
  end
end
