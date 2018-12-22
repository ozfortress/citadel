FactoryBot.define do
  factory :user_comment_edit, class: User::CommentEdit do
    association :created_by, factory: :user
    association :comment, factory: :user_comment
    content { 'This person should get banned' }
  end
end
