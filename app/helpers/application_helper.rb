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
    when :teams
      controller_name == 'teams'
    when :leagues
      controller_name == 'leagues'
    when :meta
      controller.is_a? MetaController
    end
  end

  def markdown(source)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::Safe.new)
    raw @markdown.render(source)
  end
end
