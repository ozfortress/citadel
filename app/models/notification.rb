class Notification < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :read, inclusion: { in: [true, false] }
  validates :message, presence: true, length: { in: 1..128 }
  validates :link, presence: true, length: { in: 1..128 }
end
