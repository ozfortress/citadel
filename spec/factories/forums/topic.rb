FactoryGirl.define do
  factory :forums_topic, class: 'Forums::Topic' do
    parent nil
    association :created_by, factory: :user
    name 'General Discussions'
  end
end
