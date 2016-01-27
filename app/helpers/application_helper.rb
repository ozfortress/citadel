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
      controller_name == 'meta'
    end
  end

  def needs_meta?
    user_signed_in? && current_user.can?(:edit, :games)
  end
end
