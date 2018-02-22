FactoryBot.define do
  factory :user_comment, class: User::Comment do
    association :created_by, factory: :user
    user
    content 'This person should get banned'
    content_render_cache 'This person should get banned'
  end
end
