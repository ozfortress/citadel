module Forums
  class ThreadPresenter < BasePresenter
    presents :thread

    def created_by
      @created_by ||= present(thread.created_by)
    end

    def link(options = {})
      link_to(thread.title, forums_thread_path(thread), options)
    end

    def breadcrumbs
      crumbs = path_objects.map { |path| content_tag(:li, path, class: 'breadcrumb-item') }
      safe_join(crumbs, '')
    end

    def created_at
      thread.created_at.strftime('%c')
    end

    def created_at_in_words
      time_ago_in_words thread.created_at
    end

    def status_classes
      cls = []
      cls << 'locked-thread' if thread.locked
      cls << 'hidden-thread' if thread.hidden
      cls << 'pinned-thread' if thread.pinned
      safe_join(cls, ' ')
    end

    def status_icons
      icons = []
      icons << locked_icon if thread.locked
      icons << hidden_icon if thread.hidden
      icons << pinned_icon if thread.pinned
      safe_join(icons, '')
    end

    def to_s
      thread.title
    end

    private

    def path_objects
      present_collection(thread.path).map(&:link)
    end

    def locked_icon
      inline_svg_tag('open_iconic/lock-locked.svg', title: 'Locked', class: 'icon fill-secondary mr-1')
    end

    def hidden_icon
      inline_svg_tag('eye-hide.svg', title: 'Hidden', class: 'icon fill-secondary mr-1')
    end

    def pinned_icon
      inline_svg_tag('open_iconic/pin.svg', title: 'Pinned', class: 'icon fill-success mr-1')
    end
  end
end
