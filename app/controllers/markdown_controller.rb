class MarkdownController < ApplicationController
  def markdown_preview
    escape = params[:escape] == 'true'

    # rubocop:disable Rails/OutputSafety
    render html: MarkdownRenderer.render(request.body.string, escape).html_safe, layout: false
    # rubocop:enable Rails/OutputSafety
  end
end
