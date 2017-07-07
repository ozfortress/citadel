class Team
  class PlayerPresenter < BasePresenter
    presents :player

    def user
      @user ||= present(player.user)
    end

    def leave_button
      content = safe_join(['Leave', tag(:span, class: 'glyphicon glyphicon-remove')])

      link_to(content, leave_team_path(player.team),
              method: :patch, class: 'btn btn-danger', data: { confirm: leave_confirm_message })
    end

    def kick_button
      content = safe_join(['Kick', tag(:span, class: 'glyphicon glyphicon-remove')])

      link_to(content, kick_team_path(player.team, user_id: player.user.id),
              method: :patch, class: 'btn btn-danger', data: { confirm: kick_confirm_message })
    end

    def leave_confirm_message
      request = player.user.roster_transfer_requests.pending.joining.first
      if request
        "You are pending a transfer for #{request.league.name}. "
      else
        ''
      end + 'Are you sure you want to leave this team?'
    end

    def kick_confirm_message
      "Are you sure you want to kick #{player.user.name}?"
    end
  end
end
