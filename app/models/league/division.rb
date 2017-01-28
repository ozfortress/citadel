require 'match_seeder/seeder'

class League
  class Division < ApplicationRecord
    include MatchSeeder

    belongs_to :league, inverse_of: :divisions
    has_many :rosters, inverse_of: :division, class_name: 'Roster'
    has_many :matches, -> { order(round_number: :desc, created_at: :asc) },
             through: :rosters, source: :home_team_matches, class_name: 'Match'

    has_many :transfer_requests, through: :rosters, class_name: 'Roster::TransferRequest'

    validates :name, presence: true, length: { in: 1..64 }

    alias_attribute :to_s, :name
  end
end
