class TeamInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :team

  def accept
    Transfer.create!(is_joining?: true, user: user, team: team)
    destroy
  end

  def decline
    destroy
  end
end
