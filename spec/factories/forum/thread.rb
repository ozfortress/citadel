FactoryGirl.define do
  factory :forum_thread, class: 'Forum::Thread' do
    association :topic, factory: :forum_topic
    association :created_by, factory: :user
    title 'Check this out'
  end
end
