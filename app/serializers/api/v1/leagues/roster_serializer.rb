module API
  module V1
    module Leagues
      class RosterSerializer < ActiveModel::Serializer
        type :roster

        attributes :id, :name, :description, :disbanded
        attribute(:division) { object.division.name }

        has_many :users, key: :players, serializer: UserSerializer
        has_many :matches, serializer: MatchSerializer
      end
    end
  end
end
