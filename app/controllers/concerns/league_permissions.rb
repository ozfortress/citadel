module LeaguePermissions
  extend ActiveSupport::Concern

  def user_can_edit_leagues?
    user_signed_in? && current_user.can?(:edit, :leagues)
  end

  def user_can_edit_league?(league = nil)
    league ||= @league

    user_signed_in? && (current_user.can?(:edit, :leagues) ||
                        current_user.can?(:edit, league))
  end
end
