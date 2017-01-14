module TeamPermissions
  extend ActiveSupport::Concern

  def user_can_create_team?
    user_signed_in? && current_user.can?(:use, :teams)
  end

  def user_can_edit_team?(team = nil)
    team ||= @team

    user_signed_in? && current_user.can?(:edit, team) && current_user.can?(:use, :teams) ||
      user_can_edit_teams?
  end

  def user_can_edit_teams?
    user_signed_in? && current_user.can?(:edit, :teams)
  end
end
