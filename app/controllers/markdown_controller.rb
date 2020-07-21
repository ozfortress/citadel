class MarkdownController < ApplicationController
  def markdown_preview
    escape = params[:escape] == 'true'

    data = request.body.read

    # rubocop:disable Rails/OutputSafety
    render html: MarkdownRenderer.render(data, escape).html_safe, layout: false
    # rubocop:enable Rails/OutputSafety
  end
end
