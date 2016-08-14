class UserPresenter < ActionPresenter::Base
  presents :user

  delegate :id, to: :user
  delegate :name, to: :user
  delegate :steam_id_nice, to: :user

  def link(label = nil)
    label ||= user.name
    link_to(label, user_path(user))
  end

  def avatar_link
    image_tag(user.avatar.thumb.url, class: 'avatar center-block')
  end

  def steam_link
    link_to(user.steam_id_nice, user.steam_profile_url, target: '_blank')
  end

  def titles(options = {})
    team = options[:team]

    titles = ''.html_safe
    klass = 'badge alert-danger'
    titles += content_tag :span, 'captain', class: klass if team && user.can?(:edit, team)
    titles += content_tag :span, 'admin', class: klass   if user.admin?
    titles
  end

  def transfer_listing(league)
    elements = [link, league_status(league)]
    elements.join(' ').html_safe
  end

  def league_status(league)
    elements = [roster_status(league), transfer_status(league)]
    elements = elements.select { |e| !e.empty? }
    elements.select { |e| !e.empty? }.join(', ').html_safe
  end

  def roster_status(league)
    transfers = league.players.where(user: user, approved: true)

    if transfers.exists?
      roster = transfers.first.roster
      "on roster '#{present(roster).link}'".html_safe
    else
      ''
    end
  end

  def transfer_status(league)
    transfers = league.transfers.where(user: user, approved: false)

    if transfers.exists?
      present(transfers.first).transfer_message
    else
      ''
    end
  end
end
