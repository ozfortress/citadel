class TeamInvite < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :team

  validates :user, presence: true
  validates :team, presence: true

  after_create do
    user.notify!("You have been invited to join the team'#{team.name}'.", user_path(user))
  end

  before_destroy do
    message = if team.on_roster?(user)
                "'#{user.name}' has joined the team '#{team.name}'!"
              else
                "'#{user.name}' has declined the invitation to join '#{team.name}'."
              end

    User.get_revokeable(:edit, team).each do |captain|
      captain.notify!(message, user_path(user))
    end
  end

  def accept
    team.add_player!(user)
    destroy
  end

  def decline
    destroy
  end
end
