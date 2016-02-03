module LeaguePermissions
  extend ActiveSupport::Concern

  def user_can_edit_leagues?
    user_signed_in? && current_user.can?(:edit, :competitions)
  end

  def user_can_edit_league?
    user_signed_in? && (current_user.can?(:edit, @competition) || current_user.can?(:edit, :competitions))
  end
end
