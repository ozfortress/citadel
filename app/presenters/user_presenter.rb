class UserPresenter < ActionPresenter::Base
  presents :user

  delegate :id, to: :user
  delegate :name, to: :user
  delegate :==, to: :user

  def link(label = nil)
    label ||= user.name
    link_to(label, user_path(user))
  end

  def steam_link
    link_to(user.steam_id_nice, user.steam_profile_url, target: '_blank')
  end

  def listing(options = {})
    html = ''.html_safe
    html += image_tag(user.avatar.thumb.url) if user.avatar?
    html += link
    html += " [#{steam_link}]".html_safe unless options[:steam] == false
    html += "<sub>#{titles(options)}</sub>".html_safe unless options[:titles] == false

    html
  end

  def titles(options = {})
    team = options[:team]

    titles = []
    titles << 'captain' if team && user.can?(:edit, team)
    titles << 'admin'   if user.admin?

    titles.join(', ')
  end

  def transfer_listing(competition, options = {})
    elements = [listing(options), roster_status(competition), transfer_status(competition)]
    elements = elements.select { |e| !e.empty? }
    elements.join(', ').html_safe
  end

  def roster_status(competition)
    transfers = competition.players.where(user: user, approved: true)

    if transfers.exists?
      roster = transfers.first.roster
      "on roster '#{present(roster).link}'".html_safe
    else
      ''
    end
  end

  def transfer_status(competition)
    transfers = competition.transfers.where(user: user, approved: false)

    if transfers.exists?
      present(transfers.first).transfer_message
    else
      ''
    end
  end
end
