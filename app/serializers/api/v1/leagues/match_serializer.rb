module API
  module V1
    module Leagues
      class MatchSerializer < ActiveModel::Serializer
        type :match

        attributes :id, :forfeit_by, :status, :round_name, :round_number, :notice
        attributes :created_at

        belongs_to :league
        has_one :home_team, serializer: RosterSerializer
        has_one :away_team, serializer: RosterSerializer
      end
    end
  end
end
