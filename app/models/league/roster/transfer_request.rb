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

      validate :unique_within_league_check,                  if: :pending?
      validate :on_team_check,                               if: :pending?
      validate :on_roster_check,                             if: :pending?
      validate :active_roster_check,                         if: :pending?
      validate :league_permissions_check,                    if: :pending?
      validate :roster_size_limits_check,                    if: :pending?
      validate :leaving_roster_size_limits_check, if: :pending?

      scope :pending, -> { where(approved_by: nil, denied_by: nil) }
      scope :approved, -> { where.not(approved_by: nil) }
      scope :denied, -> { where.not(denied_by: nil) }
      scope :joining, -> { where(is_joining: true) }
      scope :leaving, -> { where(is_joining: false) }

      before_validation :set_leaving_roster, if: :new_record?

      def approve(user)
        transaction do
          approval_checks || raise(ActiveRecord::Rollback)

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
        transaction do
          update(denied_by: user) || raise(ActiveRecord::Rollback)

          denial_checks || raise(ActiveRecord::Rollback)
        end

        # Reset updated attributes manually
        self.denied_by = nil unless errors.empty?

        !pending?
      end

      def cancel
        transaction do
          destroy || raise(ActiveRecord::Rollback)

          denial_checks || raise(ActiveRecord::Rollback)
        end

        destroyed?
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

      def self.leaving_roster(roster)
        pending.where(roster: roster, is_joining: false).or(pending.where(leaving_roster: roster))
      end

      def self.joining_roster(roster)
        pending.where(roster: roster, is_joining: true)
      end

      private

      def set_leaving_roster
        self.leaving_roster = league&.roster_for(user) if leaving_roster.blank? && is_joining?
      end

      def approval_checks
        validate
        roster_size_limits_check(tentative: false)
        leaving_roster_size_limits_check(tentative: false)

        errors.empty?
      end

      def denial_checks
        if is_joining?
          roster_size_limits_when_leaving_check
        else
          roster_size_limits_when_joining_check
        end

        leaving_roster_size_limits_check

        errors.empty?
      end

      def propagate_players!
        if is_joining?
          leaving_roster&.remove_player!(user)
          roster.add_player!(user)
        else
          roster.remove_player!(user)
        end
      end

      def unique_within_league_check
        return unless user.present? && roster.present? && is_joining?

        if league.transfer_requests.pending.where(user: user).where.not(id: id).exists?
          errors.add(:user_id, 'Is already pending a transfer')
        end
      end

      def on_team_check
        return unless user.present? && roster.present? && is_joining?

        errors.add(:user_id, 'Must be on the team to be transferred to the roster') unless roster.team.on_roster?(user)
      end

      def on_roster_check
        return unless user.present? && roster.present?

        if roster.on_roster?(user)
          errors.add(:user_id, 'Is already on the roster') if is_joining?
        else
          errors.add(:user_id, 'Is not on the roster') unless is_joining?
        end
      end

      def active_roster_check
        errors.add(:base, 'Roster is disbanded') if roster.present? && roster.disbanded?
      end

      def league_permissions_check
        return unless user.present? && is_joining?

        errors.add(:base, 'User is banned from leagues') unless user.can?(:use, :leagues)
      end

      def roster_size_limits_check(tentative: true)
        return unless user.present? && roster.present?

        if is_joining?
          roster_size_limits_when_joining_check(tentative: tentative)
        else
          roster_size_limits_when_leaving_check(tentative: tentative)
        end
      end

      def roster_size_limits_when_joining_check(tentative: true)
        max_players = league.max_players

        if roster_size(roster, 1, tentative) > max_players && max_players.positive?
          errors.add(:base, 'Would result in too many players on roster')
        end
      end

      def roster_size_limits_when_leaving_check(tentative: true)
        if roster_size(roster, -1, tentative) < league.min_players
          errors.add(:base, 'Would result in too few players on roster')
        end
      end

      def leaving_roster_size_limits_check(tentative: true)
        return unless user.present? && roster.present? && leaving_roster.present?
        return if leaving_roster.disbanded?

        if roster_size(leaving_roster, -1, tentative) < league.min_players
          errors.add(:base, "Would cause #{leaving_roster.name} to have too few players")
        end
      end

      def roster_size(roster, diff, tentative)
        size = tentative ? roster.tentative_player_count : roster.players.size
        size += diff if (!persisted? || !tentative) && pending?
        size
      end
    end
  end
end
