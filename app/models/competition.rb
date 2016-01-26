class Competition < ActiveRecord::Base
  belongs_to :format
  has_many   :devisions

  validates :name, presence: true, length: { in: 1..64 }
  validates :description, presence: true
end
