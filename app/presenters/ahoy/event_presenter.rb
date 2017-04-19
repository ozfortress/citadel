module Ahoy
  class EventPresenter < ActionPresenter::Base
    presents :event

    delegate :visit, to: :event
    delegate :name,  to: :event

    delegate :ip,      to: :visit, allow_nil: true
    delegate :user,    to: :visit, allow_nil: true
    delegate :api_key, to: :visit, allow_nil: true

    def client
      user&.name || api_key&.user&.name || api_key&.name
    end
  end
end
