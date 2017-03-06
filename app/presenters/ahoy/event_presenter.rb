module Ahoy
  class EventPresenter < ActionPresenter::Base
    presents :event

    delegate :visit, to: :event
    delegate :name, to: :event

    def ip
      visit.ip if visit
    end

    def user
      visit.user if visit
    end

    def api_key
      visit.api_key if visit
    end

    def client
      if user
        user.name
      elsif api_key
        if api_key.user
          api_key.user.name
        else
          api_key.name
        end
      end
    end
  end
end
