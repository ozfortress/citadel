class Division < ActiveRecord::Base
  belongs_to :competition

  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true
end
