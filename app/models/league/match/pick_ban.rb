class League
  class Match
    class PickBan < ApplicationRecord
      default_scope { order(:created_at) }

      belongs_to :match,     class_name: 'Match'
      belongs_to :picked_by, class_name: 'User', optional: true
      belongs_to :map,       class_name: 'Map',  optional: true

      enum kind: [:pick, :ban]
      enum team: [:home_team, :away_team]

      scope :pending,   -> { where(picked_by: nil) }
      scope :completed, -> { where.not(picked_by: nil) }

      validate :map_and_pick_present

      delegate :league, to: :match

      def submit(user, map)
        match.rounds.create!(map: map) if pick?

        update(picked_by: user, map: map)
      end

      private

      def map_and_pick_present
        if map
          errors.add(:picked_by, 'must be present') unless picked_by
        elsif picked_by
          errors.add(:map, 'must be present')
        end
      end
    end
  end
end
