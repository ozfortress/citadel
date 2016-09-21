module Forums
  class PostEdit < ApplicationRecord
    default_scope { order(created_at: :desc) }

    belongs_to :post
    belongs_to :created_by, class_name: 'User'

    validates :content, presence: true

    self.per_page = 8
  end
end
