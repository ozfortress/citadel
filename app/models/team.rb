class Team < ActiveRecord::Base
  belongs_to :format

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true
end
