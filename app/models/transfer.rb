class Transfer < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :is_joining?, presence: true
end
