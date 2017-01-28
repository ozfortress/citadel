module Forums
  class PostEdit < ApplicationRecord
    default_scope { order(created_at: :desc) }

    belongs_to :post, inverse_of: :edits, counter_cache: :edits_count
    belongs_to :created_by, class_name: 'User'

    validates :content, presence: true

    self.per_page = 8
  end
end
