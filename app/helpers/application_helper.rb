module ApplicationHelper
  include ApplicationPermissions

  def navbar_class(name)
    if navbar_active?(name)
      'active'
    else
      ''
    end
  end

  def navbar_active?(name)
    case name
    when :home
      controller_name == 'pages' && action_name == 'home'
    when :recruitment
      controller_name == 'users' && action_name == 'index'
    when :admin
      controller.is_a? AdminController
    else
      controller_name == name.to_s
    end
  end

  def markdown(source)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::Safe.new)
    raw @markdown.render(source)
  end

  def format_options
    Format.all.collect { |format| [format.to_s, format.id] }
  end

  def divisions_select
    @competition.divisions.all.collect { |div| [div.to_s, div.id] }
  end

  def user_listing(user = nil, options = {})
    user ||= @user

    html = ''.html_safe
    html += image_tag(user.avatar.thumb.url) if user.avatar?
    html += link_to(user.name, user_path(user))
    html += " [#{link_to user.steam_id_nice, user.steam_profile_url, target: '_blank'}]".html_safe
    html += user_titles(user, options) unless options[:titles] == false

    html
  end

  def user_titles(user = nil, options = {})
    team ||= @team || options[:team]

    titles = []
    titles << 'leader' if team && user.can?(:edit, team)
    titles << 'admin'  if user.admin?

    " <sub>#{titles.join(', ')}</sub> ".html_safe
  end
end
