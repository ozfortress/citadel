class Transfer < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :team, presence: true
  validates :user, presence: true
end
