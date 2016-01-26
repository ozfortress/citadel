class Game < ActiveRecord::Base
  has_many :formats

  validates :name, presence: true, uniqueness: true, length: { in: 1..128 }
end
