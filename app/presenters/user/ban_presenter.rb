class User
  class BanPresenter < BasePresenter
    presents :ban

    def name
      'Banned from ' + ban.class.subject.to_s.capitalize
    end

    def title_text
      safe_join([expire_s, reason_s], tag(:br))
    end

    def started_at
      ban.created_at.strftime('%c')
    end

    def terminated_at
      return 'N/A' unless ban.terminated_at
      ban.terminated_at.strftime('%c')
    end

    def duration
      return 'Indefinite' unless ban.terminated_at
      distance_of_time_in_words(ban.terminated_at - Time.zone.now)
    end

    def delete_button
      content = safe_join(["Expunge ", content_tag(:div, '', class: 'glyphicon glyphicon-remove')])
      url_params = { action_: model.action, subject: model.subject }
      options = {
        method: :delete, class: 'btn btn-danger',
        data: { confirm: 'Are you sure you want to expunge this ban?' }
      }

      link_to content, user_ban_path(ban.user, ban, url_params), options
    end

    private

    def expire_s
      if !ban.terminated_at
        'Indefinite Ban.'
      elsif ban.active?
        "Ban expires in #{duration}."
      else
        "Ban expired #{duration} ago."
      end
    end

    def reason_s
      ban.reason
    end

    def model
      ban.class
    end
  end
end
