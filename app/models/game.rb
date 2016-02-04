class Game < ActiveRecord::Base
  has_many :formats
  has_many :competitions, through: :formats

  validates :name, presence: true, uniqueness: true, length: { in: 1..128 }

  def public_competitions
    competitions.where(private: false)
  end
end
