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
    @markdown_renderer = Redcarpet::Render::HTML.new(escape_html: true, hard_wrap: true)
    @markdown ||= Redcarpet::Markdown.new(@markdown_renderer,
                                          autolink: true, strikethrough: true,
                                          underline: true)
    raw @markdown.render(source)
  end

  def format_options
    Format.all.collect { |format| [format.to_s, format.id] }
  end

  def divisions_select
    @competition.divisions.all.collect { |div| [div.to_s, div.id] }
  end

  # The ActionPresenter #present_collection is broken
  def present_collection(collection, &block)
    collection.to_a.compact.map do |object|
      present(object, &block)
    end
  end
end
