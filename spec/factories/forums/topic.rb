FactoryBot.define do
  factory :forums_topic, class: 'Forums::Topic' do
    parent { nil }
    association :created_by, factory: :user
    locked { false }
    pinned { false }
    hidden { false }
    isolated { false }
    default_hidden { false }
    description { 'a *sample* description' }
    name { 'General Discussions' }
  end
end
