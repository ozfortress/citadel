class Format < ActiveRecord::Base
  belongs_to :game
  has_many   :teams
  has_many   :competitions

  validates :name, presence: true, uniqueness: true, length: { in: 1..128 }
  validates :description, presence: true
  validates :player_count, presence: true,
                           numericality: { greater_than: 0, less_than_or_equal_to: 32 }
end
