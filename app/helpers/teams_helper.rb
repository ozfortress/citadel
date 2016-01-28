module TeamsHelper
  def format_options
    Format.all.map do |format|
      ["#{format.game.name}: #{format.name}", format.id]
    end
  end

  def teams
    Team.all
  end

  def users_who_can_edit
    User.get_revokeable(:edit, @team)
  end
end
