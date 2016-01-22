class PagesController < ApplicationController
  def home
    renderer = Redcarpet::Render::HTML.new
    @markdown = Redcarpet::Markdown.new(renderer)
  end
end
