class User
  class Notification < ApplicationRecord
    belongs_to :user

    validates :read, inclusion: { in: [true, false] }
    validates :message, presence: true
    validates :link, presence: true
  end
end
