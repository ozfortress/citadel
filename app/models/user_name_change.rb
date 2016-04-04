class UserNameChange < ActiveRecord::Base
  belongs_to :user
  belongs_to :approved_by, class_name: 'User'
  belongs_to :denied_by, class_name: 'User'

  validates :user, presence: true
  validates :name, presence: true, length: { in: 1..64 }
end
