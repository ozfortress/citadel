module TeamsHelper
  def teams
    Team.all
  end

  def users_who_can_edit
    User.get_revokeable(:edit, @team)
  end

  def transfers
    Transfer.where(team: @team).order('created_at DESC').all
  end
end
