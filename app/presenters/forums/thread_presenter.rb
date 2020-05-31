module Forums
  class ThreadPresenter < BasePresenter
    presents :thread

    def link(options = {})
      link_to(thread.title, forums_thread_path(thread), options)
    end

    def breadcrumbs
      crumbs = path_objects.map { |path| content_tag(:li, path, class: 'breadcrumb-item') }
      safe_join(crumbs, '')
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
      inline_svg_tag('open_iconic/lock-locked.svg', title: 'Locked', class: 'icon icon-locked mr-1')
    end

    def hidden_icon
      inline_svg_tag('svgrepo/hide.svg', title: 'Hidden', class: 'icon icon-hidden mr-1')
    end

    def pinned_icon
      inline_svg_tag('open_iconic/pin.svg', title: 'Pinned', class: 'icon icon-pinned mr-1')
    end
  end
end
