FactoryGirl.define do
  factory :forum_topic, class: 'Forum::Topic' do
    parent_topic nil
    association :created_by, factory: :user
    name 'General Discussions'
  end
end
