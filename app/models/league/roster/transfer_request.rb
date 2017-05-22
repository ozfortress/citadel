class League
  class Roster
    class TransferRequest < ApplicationRecord
      belongs_to :roster
      belongs_to :leaving_roster, class_name: 'Roster', optional: true

      belongs_to :user
      belongs_to :created_by, class_name: 'User'

      belongs_to :approved_by, class_name: 'User', optional: true
      belongs_to :denied_by, class_name: 'User', optional: true

      delegate :league, :division, to: :roster, allow_nil: true

      validates :is_joining, inclusion: { in: [true, false] }

      validate :unique_within_league,                         if: :pending?
      validate :on_team,                                      if: :pending?
      validate :on_roster,                                    if: :pending?
      validate :active_roster,                                if: :pending?
      validate :league_permissions,                           if: :pending?
      validate :within_roster_size_limits,                    if: :pending?
      validate :within_roster_size_limits_for_leaving_roster, if: :pending?

      scope :pending, -> { where(approved_by: nil, denied_by: nil) }
      scope :approved, -> { where.not(approved_by: nil) }
      scope :denied, -> { where.not(denied_by: nil) }

      before_validation :set_leaving_roster, if: :new_record?

      def approve(user)
        transaction do
          validate || raise(ActiveRecord::Rollback)

          propagate_players!

          if persisted?
            update(approved_by: user) || raise(ActiveRecord::Rollback)
          else
            self.approved_by = user
          end
        end

        !pending?
      end

      def deny(user)
        update(denied_by: user)
      end

      def pending?
        approved_by.blank? && denied_by.blank?
      end

      def approved?
        approved_by.present?
      end

      def denied?
        denied_by.present?
      end

      private

      def set_leaving_roster
        self.leaving_roster = league&.roster_for(user) if leaving_roster.blank? && is_joining?
      end

      def propagate_players!
        if is_joining?
          leaving_roster&.remove_player!(user)
          roster.add_player!(user)
        else
          roster.remove_player!(user)
        end
      end

      def on_team
        return unless user.present? && roster.present? && is_joining?

        unless roster.team.on_roster?(user)
          errors.add(:user_id, 'must be on the team to get transferred to the roster')
        end
      end

      def on_roster
        return unless user.present? && roster.present? && !is_joining?

        errors.add(:user_id, 'is not on the roster') unless roster.on_roster?(user)
      end

      def active_roster
        return unless roster.present? && is_joining?

        errors.add(:base, 'cannot join a disbanded roster') if roster.disbanded?
      end

      def league_permissions
        return unless user.present? && is_joining?

        errors.add(:base, 'user is banned from leagues') unless user.can?(:use, :leagues)
      end

      def within_roster_size_limits
        return unless user.present? && roster.present?

        if is_joining?
          within_roster_size_limits_when_joining
        else
          within_roster_size_limits_when_leaving
        end
      end

      def within_roster_size_limits_when_joining
        max_players = league.max_players

        if roster.players.size + 1 > max_players && max_players.positive?
          errors.add(:base, 'would result in too many players on roster')
        end
      end

      def within_roster_size_limits_when_leaving
        return if roster.disbanded?

        if roster.players.size - 1 < league.min_players
          errors.add(:base, 'would result in too few players on roster')
        end
      end

      def within_roster_size_limits_for_leaving_roster
        return unless user.present? && roster.present? && leaving_roster.present?
        return if leaving_roster.disbanded?

        new_size = leaving_roster.players.size - 1
        unless new_size >= league.min_players
          errors.add(:base, "would cause #{leaving_roster.name} to have too few players")
        end
      end

      def unique_within_league
        return unless user.present? && roster.present? && is_joining?

        if league.transfer_requests.pending.where(user: user).where.not(id: id).exists?
          errors.add(:user_id, 'is already pending a transfer')
        end
      end
    end
  end
end
