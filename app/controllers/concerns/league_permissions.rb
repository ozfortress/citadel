module LeaguePermissions
  extend ActiveSupport::Concern

  def user_can_edit_leagues?
    user_signed_in? && current_user.can?(:edit, :leagues)
  end

  def user_can_edit_league?
    user_signed_in? && (current_user.can?(:edit, @league) ||
                        current_user.can?(:edit, :leagues))
  end
end
