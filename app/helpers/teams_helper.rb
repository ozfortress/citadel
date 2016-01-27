module TeamsHelper
  def format_options
    Format.all.map do |format|
      ["#{format.game.name}: #{format.name}", format.id]
    end
  end

  def teams
    Team.all
  end

  def can_edit_team?(team)
    user_signed_in? &&
      (current_user.can?(:edit, @team) || current_user.can?(:edit, :teams))
  end
end
