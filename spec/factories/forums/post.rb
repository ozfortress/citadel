FactoryBot.define do
  factory :forums_post, class: 'Forums::Post' do
    association :thread, factory: :forums_thread
    association :created_by, factory: :user
    content 'Stuff happened!!'
  end
end
