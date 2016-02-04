FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "FOOBAR#{n}" }
    sequence(:steam_id) { |n| n }
  end
end
