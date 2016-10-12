require 'match_seeder/seeder'

class League
  class Division < ApplicationRecord
    include MatchSeeder

    belongs_to :league, inverse_of: :divisions
    has_many :rosters, inverse_of: :division, class_name: 'Roster'
    has_many :matches, -> { order(round: :desc, created_at: :asc) },
             through: :rosters, source: :home_team_matches, class_name: 'Match'

    # Special association for preloading
    has_many :approved_rosters, -> { approved }, inverse_of: :division, class_name: 'Roster'

    validates :name,   presence: true, length: { in: 1..64 }

    alias_attribute :to_s, :name

    def rosters_sorted
      @rosters_sorted ||= approved_rosters.sort_by(&:sort_keys)
    end
  end
end
