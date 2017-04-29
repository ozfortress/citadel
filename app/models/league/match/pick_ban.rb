class League
  class Match
    class PickBan < ApplicationRecord
      default_scope { order(:created_at) }

      belongs_to :match,     class_name: 'Match'
      belongs_to :picked_by, class_name: 'User', optional: true
      belongs_to :map,       class_name: 'Map',  optional: true

      enum kind: [:pick, :ban]
      enum team: [:home_team, :away_team]

      validates :deferrable, inclusion: { in: [true, false] }

      validate :map_and_pick_present

      scope :pending,   -> { where(map: nil) }
      scope :completed, -> { where.not(map: nil) }

      delegate :league, to: :match

      def submit(user, map)
        match.rounds.create!(map: map) if pick?

        update(picked_by: user, map: map)
      end

      def defer!
        transaction do
          pick_bans = match.pick_bans.pending.where.not(id: id).to_a
          pick_bans.each do |pick_ban|
            pick_ban.swap_team
            pick_ban.save!
          end

          swap_team
          self.deferrable = false
          save!
        end
      end

      def pending?
        map_id.nil?
      end

      def completed?
        !pending?
      end

      def roster
        match.send(team_pick.first)
      end

      def other_roster
        match.send(team_pick.last)
      end

      def swap_team
        self.team = team_pick.last
      end

      private

      def team_pick
        if home_team?
          [:home_team, :away_team]
        else
          [:away_team, :home_team]
        end
      end

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
