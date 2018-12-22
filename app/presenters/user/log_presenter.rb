class User
  class LogPresenter < BasePresenter
    presents :log

    def user
      @user = present(log.user)
    end

    def first_seen_at
      log.first_seen_at.strftime('%c')
    end

    def last_seen_at
      log.last_seen_at.strftime('%c')
    end
  end
end
