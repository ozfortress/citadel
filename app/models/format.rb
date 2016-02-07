class Format < ActiveRecord::Base
  belongs_to :game
  has_many   :competitions

  validates :game, presence: true
  validates :name, presence: true, uniqueness: true, length: { in: 1..128 }
  validates :description, presence: true
  validates :player_count, presence: true, inclusion: 0...16

  def to_s
    "#{game.name}: #{name}"
  end
end
