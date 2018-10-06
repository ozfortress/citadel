class League
  class Match
    class PickBan < ApplicationRecord
      default_scope { order(order_number: :asc) }

      belongs_to :match,     class_name: 'Match'
      belongs_to :picked_by, class_name: 'User', optional: true
      belongs_to :map,       class_name: 'Map',  optional: true

      enum kind: [:pick, :ban, :deferred]
      enum team: [:home_team, :away_team]

      validates :deferrable, inclusion: { in: [true, false] }

      validate :map_and_pick_present

      scope :pending,   -> { where(picked_by: nil) }
      scope :completed, -> { where.not(picked_by: nil) }

      delegate :league, to: :match

      def submit(user, map)
        match.rounds.create!(map: map) if pick?

        update(picked_by: user, map: map)
      end

      def defer!(user)
        transaction do
          shift_pending_pick_bans!

          match.pick_bans.create!(order_number: order_number + 1, kind: kind, team: team_pick.last)

          self.kind = :deferred
          self.picked_by = user
          save!
        end
      end

      def pending?
        picked_by_id.nil?
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

      def shift_pending_pick_bans!
        pick_bans = match.pick_bans.pending.where.not(id: id).to_a

        pick_bans.each do |pick_ban|
          pick_ban.swap_team
          pick_ban.order_number += 1
          pick_ban.save!
        end
      end

      def team_pick
        if home_team?
          [:home_team, :away_team]
        else
          [:away_team, :home_team]
        end
      end

      def map_and_pick_present
        if map
          errors.add(:picked_by, 'Must be present') unless picked_by
        elsif picked_by && !deferred?
          errors.add(:map, 'Must be present')
        end
      end
    end
  end
end
