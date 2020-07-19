class Game < ApplicationRecord
  has_many :formats, dependent: :restrict_with_exception
  has_many :leagues, through: :formats
  has_many :maps, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true, length: { in: 1..128 }
end
