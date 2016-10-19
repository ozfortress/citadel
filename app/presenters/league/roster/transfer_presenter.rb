class League
  class Roster
    class TransferPresenter < Team::TransferPresenter
      presents :transfer
    end
  end
end
