module Forums
  class ThreadPresenter < ActionPresenter::Base
    presents :thread

    def link
      link_to(thread.title, forums_thread_path(thread))
    end

    def path
      PATH_SEP.html_safe + safe_join(path_objects, PATH_SEP)
    end

    def to_s
      thread.title
    end

    private

    def path_objects
      present_collection(thread.path).map(&:link)
    end
  end
end
