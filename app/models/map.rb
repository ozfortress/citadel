class Map < ApplicationRecord
  include MarkdownRenderCaching

  belongs_to :game
  has_many :match_rounds, class_name: 'League::Match::Round', dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true
  caches_markdown_render_for :description, escaped: false
end
