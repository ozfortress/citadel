module API
  module V1
    class LeagueSerializer < ActiveModel::Serializer
      type :league

      attributes :id, :name, :description

      has_many :rosters, serializer: Leagues::RosterSerializer
      has_many :matches, serializer: Leagues::MatchSerializer
    end
  end
end
