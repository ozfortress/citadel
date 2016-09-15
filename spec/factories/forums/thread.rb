FactoryGirl.define do
  factory :forums_thread, class: 'Forums::Thread' do
    association :topic, factory: :forums_topic
    association :created_by, factory: :user
    locked false
    pinned false
    hidden false

    title 'Check this out'
  end
end
