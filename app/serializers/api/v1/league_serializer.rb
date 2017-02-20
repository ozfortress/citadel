module API
  module V1
    class LeagueSerializer < ActiveModel::Serializer
      type :league

      attributes :id, :name, :description

      has_many :rosters, serializer: V1::Leagues::RosterSerializer
      has_many :matches, serializer: V1::Leagues::MatchSerializer
    end
  end
end
