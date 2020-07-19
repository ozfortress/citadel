class Format < ApplicationRecord
  include MarkdownRenderCaching

  belongs_to :game
  has_many   :leagues, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true, length: { in: 1..128 }
  validates :description, presence: true
  caches_markdown_render_for :description, escaped: false
  validates :player_count, presence: true, inclusion: 0...16
end
