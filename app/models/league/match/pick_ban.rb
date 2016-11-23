class League
  class Match
    class PickBan < ApplicationRecord
      belongs_to :match, class_name: 'Match'
      belongs_to :picked_by, class_name: 'User', optional: true

      enum kind: [:pick, :ban]
      enum team: [:home_team, :away_team]

      scope :pending, -> { where(picked_by: nil) }
    end
  end
end
