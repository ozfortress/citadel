class TitlePresenter < ActionPresenter::Base
  presents :title

  delegate :id, to: :title
  delegate :name, to: :title
  delegate :badge, to: :title

  def icon
    image_tag badge.thumb.url, class: 'pull-left thumbnail', title: name,
                               data: { toggle: 'tooltip', placement: 'bottom' }
  end
end
