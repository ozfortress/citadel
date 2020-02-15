module MarkdownRenderer
  RENDER_OPTIONS = {
    hard_wrap: true,
    tables: true,
  }.freeze

  PARSER_OPTIONS = {
    autolink: true,
    strikethrough: true,
    underline: true,
    no_intra_emphasis: true,
  }.freeze

  def self.render(source, escaped = true)
    if escaped
      render_escaped(source)
    else
      render_not_escaped(source)
    end
  end

  def self.render_escaped(source)
    escaped_parser.render(source)
  end

  def self.render_not_escaped(source)
    not_escaped_parser.render(source)
  end

  def self.escaped_renderer
    @escaped_renderer ||= Redcarpet::Render::HTML.new(RENDER_OPTIONS.merge(escape_html: true))
  end

  def self.not_escaped_renderer
    @not_escaped_renderer ||= Redcarpet::Render::HTML.new(RENDER_OPTIONS.merge(escape_html: false))
  end

  def self.escaped_parser
    @escaped_parser ||= Redcarpet::Markdown.new(escaped_renderer, PARSER_OPTIONS)
  end

  def self.not_escaped_parser
    @not_escaped_parser ||= Redcarpet::Markdown.new(not_escaped_renderer, PARSER_OPTIONS)
  end
end
