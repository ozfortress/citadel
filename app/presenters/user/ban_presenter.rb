class User
  class BanPresenter < ActionPresenter::Base
    presents :ban

    def name
      'Banned from ' + ban.class.subject.to_s.capitalize
    end

    def title_text
      safe_join([expire_s, reason_s], tag(:br))
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

    def duration
      distance_of_time_in_words(ban.terminated_at - Time.zone.now)
    end
  end
end
