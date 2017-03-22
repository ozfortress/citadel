module API
  module V1
    module Leagues
      module Matches
        class RoundSerializer < ActiveModel::Serializer
          type :round

          attributes :home_team_score, :away_team_score

          belongs_to :match, serializer: MatchSerializer
          belongs_to :map
        end
      end
    end
  end
end
