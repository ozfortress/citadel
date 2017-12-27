class League
  class Match
    class CommEdit < ApplicationRecord
      default_scope { order(created_at: :desc) }

      belongs_to :created_by, class_name: 'User'
      belongs_to :comm, counter_cache: :edits_count

      validates :content, presence: true
    end
  end
end
