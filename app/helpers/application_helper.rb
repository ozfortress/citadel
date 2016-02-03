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
    when :teams
      controller_name == 'teams'
    when :leagues
      controller_name == 'leagues'
    when :admin
      controller.is_a? AdminController
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
      ["#{format.game.name}: #{format.name}", format.id]
    end
  end
end
