module ApplicationHelper

  def navbar_class(name)
    if navbar_active?(name)
      'active'
    else
      ''
    end
  end

  def navbar_active?(name)
    p controller_name
    p action_name
    case name
    when :home
      controller_name == 'pages' && action_name == 'home'
    when :teams
      controller_name == 'teams'
    when :leagues
      controller_name == 'leagues'
    end
  end
end
