module ApplicationHelper
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

  def users
    User.all
  end

  def format_options
    Format.all.map do |format|
      [format.to_s, format.id]
    end
  end

  def divisions_select
    @competition.divisions.all.map do |div|
      [div.to_s, div.id]
    end
  end

  def user_listing(user = nil)
    user ||= @user

    link_to(user.name, user_path(user)) +
      " [#{link_to user.steam_id_nice, user.steam_profile_url, :target => '_blank'}]".html_safe
  end
end
