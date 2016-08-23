module Ahoy
  class EventPresenter < ActionPresenter::Base
    presents :event

    delegate :name, to: :event
    delegate :method, to: :event
    delegate :uri, to: :event
    delegate :ip, to: :event

    def user
      if event.user
        present(event.user).link
      else
        ''
      end
    end
  end
end
