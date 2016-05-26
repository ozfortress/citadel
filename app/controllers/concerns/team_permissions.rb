module TeamPermissions
  extend ActiveSupport::Concern

  def user_can_edit_team?
    user_signed_in? &&
      (current_user.can?(:edit, @team) || current_user.can?(:edit, :teams))
  end
end
