class League
  class Roster
    class Comment < ApplicationRecord
      belongs_to :user
      belongs_to :roster, class_name: 'Roster'

      validates :content, presence: true
    end
  end
end
