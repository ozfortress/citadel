FactoryBot.define do
  factory :forums_post_edit, class: 'Forums::PostEdit' do
    association :post, factory: :forums_post
    association :created_by, factory: :user
    content 'Stuff happened!!'
  end
end
