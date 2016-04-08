module TeamsHelper
  def users_who_can_edit
    User.get_revokeable(:edit, @team)
  end
end
