class League
  class Roster
    class Comment < ActiveRecord::Base
      belongs_to :user
      belongs_to :roster, class_name: 'Roster'

      validates :user,    presence: true
      validates :roster,  presence: true
      validates :content, presence: true
    end
  end
end
