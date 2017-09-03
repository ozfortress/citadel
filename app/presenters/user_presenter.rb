class UserPresenter < BasePresenter
  presents :user

  delegate :id, to: :user
  delegate :name, to: :user

  BADGE_COLORS = %w[Green Red Yellow Blue].freeze
  BADGE_CLASSES = %w[alert-success alert-danger alert-warning alert-info].freeze

  def link(label = nil)
    label ||= user.name
    link_to(label, user_path(user))
  end

  def avatar_tag
    image_tag(user.avatar.thumb.url, class: 'avatar center-block')
  end

  def created_at
    user.created_at.strftime('%c')
  end

  def steam_profile_url
    "http://steamcommunity.com/profiles/#{user.steam_64}"
  end

  def steam_link
    link_to(steam_profile_url, target: '_blank') do
      content = [
        content_tag(:span, '', class: 'glyphicon glyphicon-link small'),
        user.steam_id3,
      ]

      safe_join(content, '')
    end
  end

  def titles(options = {})
    team = options[:team]
    has_captain_label = team && user.can?(:edit, team) && user.can?(:use, :teams)

    titles = []
    titles << content_tag(:div, 'captain', class: 'label alert-danger') if has_captain_label
    titles << badge if user.badge?
    safe_join(titles, ' ')
  end

  def description
    # rubocop:disable Rails/OutputSafety
    user.description_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def notice
    # rubocop:disable Rails/OutputSafety
    user.notice_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def league_status(league)
    elements = [roster_status(league), transfer_status(league)]
    safe_join(elements.reject(&:empty?))
  end

  def roster_status(league)
    roster = league.roster_for(user)

    if roster
      safe_join(["on roster '", present(roster).link, "'"])
    else
      ''
    end
  end

  def transfer_status(league)
    request = league.transfer_requests.pending.find_by(user: user)

    if request
      present(request).transfer_message
    else
      ''
    end
  end

  def confirmation_label
    'Optional Email for Notifications ' +
      if user.confirmed?
        '(confirmed!)'
      elsif user.email?
        '(pending confirmation)'
      else
        ''
      end
  end

  def badge
    content_tag(:div, user.badge_name, class: "label #{badge_class}")
  end

  def badge_class
    if user.badge_color.between?(0, BADGE_COLORS.length)
      BADGE_CLASSES[user.badge_color]
    else
      BADGE_CLASSES.first
    end
  end
end
