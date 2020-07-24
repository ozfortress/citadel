class Game < ApplicationRecord
  has_many :formats, dependent: :destroy
  has_many :leagues, through: :formats
  has_many :maps, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { in: 1..128 }
end
