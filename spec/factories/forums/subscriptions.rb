FactoryBot.define do
  factory :forums_subscription, class: 'Forums::Subscription' do
    user
    association :topic,  factory: :forums_topic
    association :thread, factory: :forums_thread
  end
end
