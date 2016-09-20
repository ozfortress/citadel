module Forums
  class PostEdit < ApplicationRecord
    belongs_to :post
    belongs_to :created_by, class_name: 'User'

    validates :content, presence: true
  end
end
