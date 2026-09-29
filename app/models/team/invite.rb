class Team
  class Invite < ApplicationRecord
    DEFAULT_EXPIRY = 1.week
    LIMIT_PER_TEAM = 16

    belongs_to :user
    belongs_to :team

    validates :user, uniqueness: { scope: :team, conditions: -> { active } }
    validate :user_not_in_team
    validate :invite_limit

    scope :active, -> { expiry ? where(created_at: Team::Invite.expiry.ago..) : all }

    def self.expiry
      days = Rails.configuration.features.team_invite_expiry_days
      return DEFAULT_EXPIRY if days.nil?

      days = days.to_i
      days.positive? ? days.days : nil
    end

    def expired?
      expiry = self.class.expiry
      expiry ? created_at < expiry.ago : false
    end

    def accept
      transaction do
        team.add_player!(user)

        destroy || raise(ActiveRecord::Rollback)
      end
    end

    def decline
      destroy
    end

    private

    def user_not_in_team
      errors.add(:user, 'User is already in the team') if team.present? && user.present? && team.on_roster?(user)
    end

    def invite_limit
      errors.add(:user, 'Too many invites') if team.present? && team.invites.active.count >= Invite::LIMIT_PER_TEAM
    end
  end
end
