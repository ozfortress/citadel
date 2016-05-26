module Leagues
  module RostersHelper
    include RosterPermissions

    def user_can_edit_team?
      user_signed_in? &&
        (current_user.can?(:edit, @roster.team) || current_user.can?(:edit, :teams))
    end
  end
end
