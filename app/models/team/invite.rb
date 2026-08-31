class Team
  class Invite < ApplicationRecord
    LIMIT_PER_TEAM = 16

    belongs_to :user
    belongs_to :team

    validates :user, uniqueness: { scope: :team }
    validate :user_not_in_team
    validate :invite_limit

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
      errors.add(:user, 'Too many invites') if team.present? && team.invites.count >= Invite::LIMIT_PER_TEAM
    end
  end
end
