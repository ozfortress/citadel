class TeamInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :team

  def accept
    team.add_player(user)
    destroy
  end

  def decline
    destroy
  end
end
