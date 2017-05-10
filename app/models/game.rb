class Game < ApplicationRecord
  has_many :formats
  has_many :leagues, through: :formats
  has_many :maps

  validates :name, presence: true, uniqueness: true, length: { in: 1..128 }
end
