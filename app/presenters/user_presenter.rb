class UserPresenter < ActionPresenter::Base
  presents :user

  delegate :id, to: :user
  delegate :name, to: :user

  def link(label = nil)
    label ||= user.name
    link_to(label, user_path(user))
  end

  def avatar_link
    image_tag(user.avatar.thumb.url, class: 'avatar center-block')
  end

  def steam_link
    link_to(user.steam_id3, user.steam_profile_url, target: '_blank')
  end

  def titles(options = {})
    team = options[:team]
    has_captain_label = team && user.can?(:edit, team)

    titles = []
    titles << content_tag(:div, 'captain', class: 'label alert-danger')  if has_captain_label
    titles << content_tag(:div, 'admin',   class: 'label alert-success') if user.admin?
    safe_join(titles, ' ')
  end

  def description
    # rubocop:disable Rails/OutputSafety
    user.description_render_cache.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def league_status(league)
    elements = [roster_status(league), transfer_status(league)]
    safe_join(elements.select { |e| !e.empty? })
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
    request = league.transfer_requests.find_by(user: user)

    if request
      present(request).transfer_message
    else
      ''
    end
  end

  def confirmation_label
    'Email for Notifications ' +
      if user.confirmed?
        '(confirmed!)'
      elsif !user.email.blank?
        '(pending confirmation)'
      else
        ''
      end
  end
end
