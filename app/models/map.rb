class Map < ApplicationRecord
  belongs_to :game

  validates :game, presence: true
  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true

  alias_attribute :to_s, :name
end
