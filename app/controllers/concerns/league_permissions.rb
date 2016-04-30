module LeaguePermissions
  extend ActiveSupport::Concern

  def user_can_edit_leagues?
    user_signed_in? && current_user.can?(:edit, :competitions)
  end

  def user_can_edit_league?
    user_signed_in? && (current_user.can?(:edit, @competition) ||
                        current_user.can?(:edit, :competitions))
  end

  def user_can_submit_team_score?
    user_can_home_team? && @match.status == 'submitted_by_home_team' ||
      user_can_away_team? && @match.status == 'submitted_by_away_team'
  end
end
