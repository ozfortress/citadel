class League
  class Match
    class CommEdit < ApplicationRecord
      default_scope { order(created_at: :desc) }

      belongs_to :comm
      belongs_to :user

      validates :content, presence: true, length: { in: 10..1_000 }
    end
  end
end
