FactoryGirl.define do
  factory :forum_post, class: 'Forum::Post' do
    association :thread, factory: :forum_thread
    association :created_by, factory: :user
    content 'Stuff happened!!'
  end
end
