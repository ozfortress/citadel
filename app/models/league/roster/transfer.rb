class League
  class Roster
    class Transfer < ApplicationRecord
      include Rails.application.routes.url_helpers

      belongs_to :user
      belongs_to :roster, class_name: 'Roster', foreign_key: 'roster_id'
      delegate :team,     to: :roster,   allow_nil: true
      delegate :division, to: :roster,   allow_nil: true
      delegate :league,   to: :division, allow_nil: true

      validates :is_joining, inclusion: { in: [true, false] }
      validates :approved,   inclusion: { in: [true, false] }

      validate :on_team, on: :create
      validate :within_roster_size, on: :create
      validate :pending_unique_for_user, on: :create

      after_initialize :set_defaults, unless: :persisted?

      before_update do
        next unless approved? && is_joining

        transfers = league.players.where(user: user, approved: true)
        if transfers.exists?
          transfers.first.roster.remove_player!(user, approved: true)
        end
      end

      scope :approved, -> { where(approved: true) }

      after_create do
        if is_joining?
          after_create_joining
        else
          after_create_leaving
        end
      end

      after_update do
        next unless approved?

        if is_joining?
          user_msg = "The request to transfer into '#{roster.name}' for #{league.name} "\
                     'has been approved.'
          capt_msg = "The request to transfer '#{user.name}' into '#{roster.name}' for "\
                     "#{league.name} has been approved."
        else
          user_msg = "The request to transfer out of '#{roster.name}' for #{league.name} "\
                     'has been approved.'
          capt_msg = "The request to transfer '#{user.name}' out of '#{roster.name}' for "\
                     "#{league.name} has been approved."
        end

        user.notify!(user_msg, league_roster_path(league, roster))
        notify_captains(capt_msg, user_path(user))
      end

      before_destroy do
        if is_joining?
          user_msg = "The request to transfer into '#{roster.name}' for #{league.name} "\
                     'has been denied.'
          capt_msg = "The request to transfer '#{user.name}' into '#{roster.name}' for "\
                     "#{league.name} has been denied."
        else
          user_msg = "The request to transfer out of '#{roster.name}' for #{league.name} "\
                     'has been denied.'
          capt_msg = "The request to transfer '#{user.name}' out of '#{roster.name}' for "\
                     "#{league.name} has been denied."
        end

        user.notify!(user_msg, league_roster_path(league, roster))
        notify_captains(capt_msg, user_path(user))
      end

      private

      def notify_captains(message, link)
        User.get_revokeable(:edit, team).each do |captain|
          captain.notify!(message, link)
        end
      end

      def after_create_joining
        msg = if approved?
                "You have been entered in #{league.name} with '#{roster.name}'."
              else
                "It has been requested for you to transfer into '#{roster.name}' "\
                "for #{league.name}."
              end

        user.notify!(msg, league_roster_path(league, roster))
      end

      def after_create_leaving
        msg = if approved?
                "You have been removed from '#{roster.name}' for #{league.name}."
              else
                "It has been requested for you to transfer out of '#{roster.name}' "\
                "for #{league.name}."
              end

        user.notify!(msg, league_roster_path(league, roster))
      end

      def set_defaults
        if league.present? && user.present? &&
           (!league.transfers_require_approval? || !roster.approved?)
          self.approved = !is_joining? || !league.on_roster?(user)
        end
      end

      def on_team
        return unless user.present? && roster.present?

        if is_joining?
          on_team_for_joining
        else
          on_team_for_leaving
        end
      end

      def on_team_for_joining
        unless roster.team.on_roster?(user) && !roster.on_roster?(user)
          errors.add(:user_id, 'must be on the team to get transferred to the roster')
        end
      end

      def on_team_for_leaving
        unless roster.on_roster?(user)
          errors.add(:user_id, 'must be on the roster to get transferred out')
        end
      end

      def within_roster_size
        return unless roster.present? && roster.persisted? && league.present?

        if is_joining?
          within_roster_size_for_joining
        else
          within_roster_size_for_leaving
        end
      end

      def within_roster_size_for_joining
        if roster.players.size >= league.max_players && league.max_players > 0
          errors.add(:user_id, 'transferring in would make the roster too large')
        end
      end

      def within_roster_size_for_leaving
        if roster.players.size <= league.min_players
          errors.add(:user_id, 'transferring out would make the roster too small')
        end
      end

      def pending_unique_for_user
        if league.present? && user.present? && !approved? &&
           league.transfers.where(user: user, approved: false).exists?
          errors.add(:user_id, 'is already pending a transfer')
        end
      end
    end
  end
end
