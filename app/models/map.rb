class Map < ApplicationRecord
  include MarkdownRenderCaching

  belongs_to :game

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true
  caches_markdown_render_for :description, escaped: false

  alias_attribute :to_s, :name
end
